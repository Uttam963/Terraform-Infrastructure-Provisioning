resource "random_password" "appdVm_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "appdVm_password" {
  name         = "appdVm-password"
  value        = random_password.appdVm_password.result
  key_vault_id = var.key_vault_id
}

resource "azurerm_subnet" "azAppdVmSubnet" {
  name                 = "snt-${var.AppdVm_resource_group_name}-appd"
  resource_group_name  = var.AppdVm_resource_group_name
  virtual_network_name = var.AppdVm_virtual_network_name
  address_prefixes     = ["${var.AppdVm_Subnet_address_space}"]
}

resource "azurerm_public_ip" "AppdVm_public_ip" {
  name                = "appd-${var.AppdVm_resource_group_name}-ip"
  resource_group_name = var.AppdVm_resource_group_name
  location            = var.AppdVm_location
  allocation_method   = "Static"
  #domain_name_label   = "${replace(data.azurerm_resource_group.RG.name, "-", "")}-${count.index}"
}


resource "azurerm_network_security_group" "Appd_nsg" {
  name                = "vm-appd-${trimprefix(var.AppdVm_resource_group_name,"")}NSG"
  location            = var.AppdVm_location
  resource_group_name = var.AppdVm_resource_group_name

  security_rule {
    name                       = "allow_ssh_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "Appd_Nic" {
  name                = "vm-appd-${trimprefix(var.AppdVm_resource_group_name,"")}VMNic"
  location            = var.AppdVm_location
  resource_group_name = var.AppdVm_resource_group_name

  ip_configuration {
    name                          = "ipconfigvm-appd-${trimprefix(var.AppdVm_resource_group_name,"")}"
    subnet_id                     = azurerm_subnet.azAppdVmSubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.AppdVm_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "Appd_association" {
  network_interface_id      = azurerm_network_interface.Appd_Nic.id
  network_security_group_id = azurerm_network_security_group.Appd_nsg.id
}


resource "azurerm_linux_virtual_machine" "Appd_VM" {
  name                  = "vm-appd-${trimprefix(var.AppdVm_resource_group_name,"")}"
  location              = var.AppdVm_location
  resource_group_name   = var.AppdVm_resource_group_name
  network_interface_ids = [azurerm_network_interface.Appd_Nic.id]
  size                  = var.AppdVm_size
  admin_username        = "vm_admin"
  admin_password        = random_password.appdVm_password.result
  disable_password_authentication = false

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  os_disk {
    name              = "vm-appd-${trimprefix(var.AppdVm_resource_group_name," -")}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_virtual_machine_extension" "appd-sentinelone-extension" {
  name                      = "SentinelOneLinuxExtension"
  virtual_machine_id        = azurerm_linux_virtual_machine.Appd_VM.id
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
    azurerm_linux_virtual_machine.Appd_VM
  ]
}
