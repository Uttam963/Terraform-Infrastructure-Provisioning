resource "azurerm_subnet" "azSubnetaks" {
  name                 = "snt-${var.AKS_resource_group_name}-aks"
  resource_group_name  = var.AKS_resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["${var.aksSubnet_address_space}"]
}

resource "azurerm_kubernetes_cluster" "azAKS" {
  name                = "aks-${var.AKS_resource_group_name}"
  location            = var.AKS_location
  resource_group_name = var.AKS_resource_group_name
  dns_prefix          = "${var.AKS_resource_group_name}-k8s"
  kubernetes_version  = var.AKS_version
  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }
  default_node_pool {
    name                = "nodepool"
    vm_size             = var.AKS_node_size
    type                = "VirtualMachineScaleSets"
    os_disk_type        = "Managed"
    auto_scaling_enabled = true
    min_count           = 1
    max_count           = 30
    os_sku              = "Ubuntu"
    zones               = ["1", "2", "3"]
    vnet_subnet_id      = azurerm_subnet.azSubnetaks.id
  }
  linux_profile {
    admin_username = "linuxAdminName"
    ssh_key {
      key_data = var.pub_key
    }
  }
  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

}

resource "azurerm_storage_account" "azAKSstorage" {
  name                     = "${replace(var.AKS_resource_group_name, "-", "")}akssa2"
  resource_group_name      = "MC_${var.AKS_resource_group_name}_aks-${var.AKS_resource_group_name}_${var.AKS_location}"
  location                 = var.AKS_location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on               = [azurerm_kubernetes_cluster.azAKS]
}