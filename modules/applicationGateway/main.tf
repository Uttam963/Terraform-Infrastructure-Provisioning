resource "azurerm_subnet" "azSubnetagw" {
  name                 = "snt-${var.agw_resource_group_name}-agw"
  resource_group_name  = var.agw_resource_group_name
  virtual_network_name = var.agw_virtual_network
  address_prefixes     = ["${var.agwSubnet_address_space}"]
}

resource "azurerm_public_ip" "azPublicip" {
  name                    = "agw-${var.agw_resource_group_name}-ip"
  resource_group_name     = var.agw_resource_group_name
  location                = var.agw_location
  allocation_method       = "Static"
  sku                     = "Standard"
  sku_tier                = "Regional"
  zones                   = ["1", "2", "3"]
  idle_timeout_in_minutes = 4
  domain_name_label       = replace(var.agw_resource_group_name, "-", "")
  
}

locals {
  ssl_certificate_dev             = var.ssl_certificate_name
  backend_address_pool_name_web   = "${replace(var.agw_resource_group_name,"-","")}.xyz.com"
  backend_address_pool_name_api   = "${replace(var.agw_resource_group_name,"-","")}-api.xyz.com"
  backend_address_pool_name_error = "apology"
  # frontend_port_name_http         = "port_80"
  # frontend_port_name_https           = "port_443"
  frontend_ip_configuration_name              = "appGatewayFrontendIP"
  http_setting_name_web_http                  = "${replace(var.agw_resource_group_name,"-","")}-web-http"
  http_setting_name_api_http                  = "${replace(var.agw_resource_group_name,"-","")}-api-http"
  listener_name_api_https                     = "${replace(var.agw_resource_group_name,"-","")}-api.xyz.com-https"
  listener_name_web_https                     = "${replace(var.agw_resource_group_name,"-","")}.xyz.com-https"
  listener_name_web_http                      = "${replace(var.agw_resource_group_name,"-","")}.xyz.com-http"
  request_routing_rule_name_api_rule          = "${replace(var.agw_resource_group_name,"-","")}-api.xyz.com"
  request_routing_rule_name_web_rule          = "${replace(var.agw_resource_group_name,"-","")}.xyz.com"
  request_routing_rule_name_web_redirect_rule = "${replace(var.agw_resource_group_name,"-","")}.xyz.com-redirect-rule"
  #redirect_configuration_name        = "${var.prefix}-web-redirect-rule"
}

resource "azurerm_application_gateway" "azAppgateway" {
  name                = "agw-${var.agw_resource_group_name}"
  resource_group_name = var.agw_resource_group_name
  location            = var.agw_location
  zones               = ["1", "2", "3"]

  identity {  
    type         = "UserAssigned"
    #identity_ids = [data.azurerm_user_assigned_identity.example.id]
    identity_ids = ["${var.identidy_ids}"]
  }
  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  waf_configuration {

    enabled          = false
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.1"
    #disabledRuleGroups = []
  }

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 10
  }
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.azSubnetagw.id
  }
  ssl_certificate {
    name                = local.ssl_certificate_dev
    key_vault_secret_id = var.keyvault_ssl_dev
  }
  frontend_ip_configuration {
    name                          = local.frontend_ip_configuration_name
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azPublicip.id
  }
  frontend_port {
    name = "appGatewayFrontendPort"
    port = 80
  }
  frontend_port {
    name = "appGatewayFrontendPortHttps"
    port = "443"
  }

  backend_address_pool {
    name = local.backend_address_pool_name_web
  }
  backend_address_pool {
    name = local.backend_address_pool_name_api
  }
  backend_address_pool {
    name  = local.backend_address_pool_name_error
    fqdns = [""]
  }
  backend_http_settings {
    name                                = "Zuul"
    port                                = 80
    protocol                            = "Http"
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = false
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    request_timeout                     = 360
  }
  backend_http_settings {
    name                                = "appGatewayBackendHttpSettings"
    port                                = 80
    protocol                            = "Http"
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = false
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    request_timeout                     = 360
  }
  request_routing_rule {
    name                       = local.request_routing_rule_name_api_rule
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_api_https
    backend_address_pool_name  = local.backend_address_pool_name_api
    backend_http_settings_name = "Zuul"
    priority                   = 30
  }
  request_routing_rule {
    name                       = local.request_routing_rule_name_web_rule
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_web_https
    backend_address_pool_name  = local.backend_address_pool_name_web
    backend_http_settings_name = "appGatewayBackendHttpSettings"
    priority                   = 20
  }
  request_routing_rule {
    name                        = local.request_routing_rule_name_web_redirect_rule
    rule_type                   = "Basic"
    http_listener_name          = local.listener_name_web_http
    redirect_configuration_name = local.request_routing_rule_name_web_redirect_rule
    priority                    = 10
  }
  redirect_configuration {
    name                 = local.request_routing_rule_name_web_redirect_rule
    redirect_type        = "Permanent"
    target_listener_name = local.listener_name_web_https
    include_path         = "true"
    include_query_string = "true"
  }

  http_listener {
    name                           = local.listener_name_api_https
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "appGatewayFrontendPortHttps"
    protocol                       = "Https"
    ssl_certificate_name           = local.ssl_certificate_dev
    host_name                      = "${replace(var.agw_resource_group_name, "-", "")}-api.xyz.com"
  }
  http_listener {
    name                           = local.listener_name_web_https
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "appGatewayFrontendPortHttps"
    protocol                       = "Https"
    ssl_certificate_name           = local.ssl_certificate_dev
    host_name                      = "${replace(var.agw_resource_group_name, "-", "")}.xyz.com"
  }
  http_listener {
    name                           = local.listener_name_web_http
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "appGatewayFrontendPort"
    protocol                       = "Http"
    host_name                      = "${replace(var.agw_resource_group_name, "-", "")}.xyz.com"
  }
}

