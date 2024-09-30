resource "random_password" "vm_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-password"
  value        = random_password.vm_password.result
  key_vault_id = var.key_vault_id
}

resource "azurerm_subnet" "azVmSubnet" {
  name                 = "snt-${var.VM_resource_group_name}-els"
  resource_group_name  = var.VM_resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["${var.vmSubnet_address_space}"]
}

# Create an availability set
resource "azurerm_availability_set" "azAvalibilitySet" {
  name                = "es-data-0-av-set"
  location            = var.VM_location  
  resource_group_name = var.VM_resource_group_name
  platform_update_domain_count = 20
  platform_fault_domain_count = 2
}


resource "azurerm_network_interface" "azNic" {
  count               = var.VM_count
  name                = "es-data-${count.index}-nic"
  location            = var.VM_location
  resource_group_name = var.VM_resource_group_name

  ip_configuration {
    name                          = "ipconfigvm-${var.VM_resource_group_name}"
    subnet_id                     = azurerm_subnet.azVmSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_managed_disk" "data_disk" {
  count                 = var.VM_count
  name                 = "es-data-${count.index}-datadisk1"
  location             = var.VM_location
  resource_group_name  = var.VM_resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_linux_virtual_machine" "azVM" {
  count                 = var.VM_count
  name                  = "es-data-${count.index}"
  location              = var.VM_location
  resource_group_name   = var.VM_resource_group_name
  network_interface_ids = [element(azurerm_network_interface.azNic.*.id, count.index)]
  size                  = var.VM_size
  admin_username        = "es_admin"
  admin_password        = random_password.vm_password.result
  disable_password_authentication = false

  availability_set_id = azurerm_availability_set.azAvalibilitySet.id


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = var.os_version
    version   = "latest"
  }
  os_disk {
    name              = "es-data-${count.index}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  # storage_data_disk {
  #   name              = azurerm_managed_disk.data_disk[count.index].name
  #   managed_disk_id   = azurerm_managed_disk.data_disk[count.index].id
  #   create_option     = "Attach"
  #   caching           = "None"
  #   lun               = 0
  #   disk_size_gb      = 128
  # }
  # os_profile {
  #   computer_name  = "es-data-${count.index}"

  # }
  # os_profile_linux_config {
  #   disable_password_authentication = false
  # }
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  count              = var.VM_count
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.azVM[count.index].id
  lun                = "0"
  caching            = "None"
}

resource "azurerm_lb" "azLB" {
  name                = "es-internal-lb"
  location            = var.VM_location
  resource_group_name = var.VM_resource_group_name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "LBFE"
    subnet_id = azurerm_subnet.azVmSubnet.id
    #private_ip_address_allocation = Static
  }
}

# Configure load balancer backend pool
resource "azurerm_lb_backend_address_pool" "azLbBackendPool" {
  name                  = "LBBE"
  loadbalancer_id       = azurerm_lb.azLB.id
}

# Attach VMs to the backend pool
resource "azurerm_network_interface_backend_address_pool_association" "azBackendVM" {
  count                 = var.VM_count
  network_interface_id  = azurerm_network_interface.azNic[count.index].id
  ip_configuration_name = "ipconfigvm-${var.VM_resource_group_name}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.azLbBackendPool.id
}

resource "azurerm_virtual_machine_extension" "setupelastic" {
  count                = var.VM_count
  name                 = "setup-elastic"
  virtual_machine_id   = azurerm_linux_virtual_machine.azVM[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
 
  protected_settings = <<PROT
    {
        "script": "${base64encode(file(var.setupelasticfile))}"
    }
    PROT
  
  depends_on = [
    azurerm_linux_virtual_machine.azVM
  ]   

}

resource "azurerm_virtual_machine_extension" "sentinelone-extension" {
  count                     = var.VM_count
  name                      = "SentinelOneLinuxExtension"
  virtual_machine_id        = azurerm_linux_virtual_machine.azVM[count.index].id
  publisher                 = "SentinelOne.LinuxExtension"
  type                      = "LinuxExtension"
  type_handler_version      = "1.2"
  automatic_upgrade_enabled = false
  settings                  = <<SETTINGS
    {
      "LinuxAgentVersion": "",
      "SiteToken": ""
    }
SETTINGS

  protected_settings = <<PROTECTEDSETTINGS
    {
      "SentinelOneConsoleAPIKey": ""
    }
PROTECTEDSETTINGS

  depends_on = [
    azurerm_linux_virtual_machine.azVM
  ]
}