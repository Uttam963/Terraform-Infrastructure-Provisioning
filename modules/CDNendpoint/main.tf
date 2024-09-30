/*
resource "azurerm_cdn_profile" "profile" {
  name                = "cdn${replace(var.cdn_rg_group,"-","")}"
  location            = "Global"
  resource_group_name = var.cdn_rg_group
  sku                 = "Standard_Microsoft"

}
*/

data "azurerm_cdn_profile" "example" {
  name                = lower("cdn${var.environment_type}01-cdn")
  resource_group_name = lower("${var.environment_type}-01")
}

# resource "azurerm_cdn_profile" "example" {
#   name                = "cdn${trimprefix(replace(var.cdn_rg_group_name,"-",""),"ssp")-cdn}"
#   location            = var.cdn_rg_group_location
#   resource_group_name = var.cdn_rg_group_name
#   sku                 = "Standard_Verizon"
# }

resource "azurerm_cdn_endpoint" "endpoint" {
  # count               = var.create_cdn_endpoint ? 1 : 0
  name                = "cdn${trimprefix(replace(var.cdn_rg_group_name,"-",""),"ssp")}"
  profile_name        = data.azurerm_cdn_profile.example.name
  location            = "Global"
  resource_group_name = data.azurerm_cdn_profile.example.resource_group_name
  origin_host_header  = var.primary_web_host

  origin {
    name      = "stglstvw${replace(var.cdn_rg_group_name,"-","")}"
    host_name = var.primary_web_host
  }

  depends_on = [ data.azurerm_cdn_profile.example ]
}