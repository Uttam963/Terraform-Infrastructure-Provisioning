resource "azurerm_maps_account" "name" {
  name                = "amp-${var.amp_resource_group_name}"
  resource_group_name = var.amp_resource_group_name
  location            = "Global"
  sku_name            = "G2"
}