resource "azurerm_virtual_network" "azVnet" {
  name                = "vnet-${var.vnet_resource_group_name}"
  address_space       = ["${var.vnet_address_space}"]
  location            = var.vnet_resource_group_location
  resource_group_name = var.vnet_resource_group_name
}