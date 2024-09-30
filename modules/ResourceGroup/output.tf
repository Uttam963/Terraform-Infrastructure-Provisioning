output "resource_group_name" {
  value = var.create_resource_group ? azurerm_resource_group.azRG[0].name : data.azurerm_resource_group.azRG[0].name
}

output "resource_group_location" {
  value = var.create_resource_group ? azurerm_resource_group.azRG[0].location : data.azurerm_resource_group.azRG[0].location
}