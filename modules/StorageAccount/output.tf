# output "storage_account_name" {
#   value = var.create_storage_account ? azurerm_storage_account.example[0].name : data.azurerm_storage_account.example[0].name
# }

output "stg_primary_web_host" {
    value = azurerm_storage_account.example.primary_web_host
}