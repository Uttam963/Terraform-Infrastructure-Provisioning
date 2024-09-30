locals {
  azure_default_tags = {
    Cost_Center_ID: var.Cost_Center_ID
    Environment_Type: var.Environment_Type
    Product_Group: var.Product_Group
    Customer: var.Customer
    Owner: var.Owner
  }
}

# Resource group
data "azurerm_resource_group" "azRG" {
  count = var.create_resource_group ? 0 : 1
  name     = var.ResourceGroup_name
}

resource "azurerm_resource_group" "azRG" {
    count         = var.create_resource_group ? 1 : 0
    name          = var.ResourceGroup_name
    location      = var.ResourceGroup_location

    tags = local.azure_default_tags
}