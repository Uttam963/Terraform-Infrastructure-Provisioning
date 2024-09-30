data "azurerm_client_config" "example" {}

resource "azurerm_key_vault" "azKeyvault" {
  name                = "kyv-${var.kyv_resource_group_name}"
  location            = var.kyv_location
  resource_group_name = var.kyv_resource_group_name
  enabled_for_disk_encryption = true
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.example.tenant_id
}

resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = azurerm_key_vault.azKeyvault.id
  tenant_id    = data.azurerm_client_config.example.tenant_id
  object_id    = data.azurerm_client_config.example.object_id

  secret_permissions = [
    "Get",
    "Set",
    "List",
  ]

  depends_on = [
    azurerm_key_vault.azKeyvault
  ]
}

resource "azurerm_key_vault_secret" "mysqlUsername" {
  name         = "mysqlUsername"
  value        = ""
  key_vault_id = azurerm_key_vault.azKeyvault.id

  depends_on = [
    azurerm_key_vault_access_policy.example
  ]
}

resource "azurerm_key_vault_secret" "mysqlPassword" {
  name         = "mysqlPassword"
  value        = ""
  key_vault_id = azurerm_key_vault.azKeyvault.id

  depends_on = [
    azurerm_key_vault_access_policy.example
  ]
}