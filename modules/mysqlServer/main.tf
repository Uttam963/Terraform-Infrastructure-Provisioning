resource "random_password" "mysql_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "mysql_password" {
  name         = "mysqladmin-password"
  value        = random_password.mysql_password.result
  key_vault_id = var.key_vault_id
}

resource "azurerm_mysql_flexible_server" "mysqlflexi" {
  name                   = "mysql-flexi-${var.mysql_resource_group_name}"
  resource_group_name    = var.mysql_resource_group_name
  location               = var.mysql_resource_group_location
  administrator_login    = "mysqladmin"
  administrator_password = random_password.mysql_password.result
  backup_retention_days  = 7
  sku_name               = var.mysql_sku_name
  storage {
    size_gb              = var.mysql_storage_gb
    iops                 = 2000
    auto_grow_enabled    = false
  }
  version = var.mysql_version
}

resource "azurerm_mysql_flexible_server_firewall_rule" "whitelist_ip" {
  name                = "VPN"
  resource_group_name = azurerm_mysql_flexible_server.mysqlflexi.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysqlflexi.name
  start_ip_address    = "0.0.0.0"  # Replace with your IP address
  end_ip_address      = "0.0.0.0"  # Replace with your IP address

  depends_on = [
    azurerm_mysql_flexible_server.mysqlflexi
  ]
}

# resource "null_resource" "initialize_db" {
#   provisioner "local-exec" {
#     command = <<EOT
#       mysql -h ${azurerm_mysql_flexible_server.mysqlflexi.fqdn} -u ${azurerm_mysql_flexible_server.mysqlflexi.administrator_login} -p ${azurerm_mysql_flexible_server.mysqlflexi.administrator_password} < sql_script.sql
#     EOT
#   }

#   depends_on = [
#     azurerm_mysql_flexible_server.mysqlflexi, azurerm_mysql_flexible_server_firewall_rule.whitelist_ip
#   ]
# }