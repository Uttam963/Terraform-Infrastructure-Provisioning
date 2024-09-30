# terraform {
#   backend "azurerm" {
#     resource_group_name   = ""
#     storage_account_name  = "terraformstgact01"
#     container_name        = "dev-terraform"
#     key                   = "terraform.tfstate"
#   }
# }

locals {
  file_content = file("${var.customer_type}.json")
  variables_data = jsondecode(local.file_content)
}

module "ResourceGroup" {
  source = "../modules/ResourceGroup"
  ResourceGroup_name = var.ResourceGroup_name
  ResourceGroup_location = var.ResourceGroup_location
  create_resource_group = var.create_resource_group
  Cost_Center_ID = var.Cost_Center_ID
  Environment_Type = var.Environment_Type
  Product_Group = var.Product_Group
  Customer = var.Customer
  Owner = var.Owner
}

module "keyVault" {
  source = "../modules/keyVault"
  kyv_resource_group_name = module.ResourceGroup.resource_group_name
  kyv_location = module.ResourceGroup.resource_group_location

  depends_on = [
    module.ResourceGroup
  ]
}

module "StorageAccount" {
  source = "../modules/StorageAccount"
  storage_account_name = "stg${replace(module.ResourceGroup.resource_group_name,"-","")}"
  storage_account_resource_group_name = module.ResourceGroup.resource_group_name
  storage_account_location = module.ResourceGroup.resource_group_location
  # create_storage_account = var.create_storage_account
  #common_tags = local.azure_common_tags

  depends_on = [
    module.ResourceGroup
  ]
}

module "CDNendpoint" {
  source = "../modules/CDNendpoint"
  cdn_rg_group_name = module.ResourceGroup.resource_group_name
  primary_web_host = module.StorageAccount.stg_primary_web_host
  environment_type = var.Environment_Type
  # create_cdn_endpoint = var.create_cdn_endpoint

  depends_on = [
    module.ResourceGroup, module.StorageAccount
  ] 
}

module "virtualNetwork" {
  source = "../modules/virtualNetwork"
  vnet_resource_group_name = module.ResourceGroup.resource_group_name
  vnet_resource_group_location = module.ResourceGroup.resource_group_location
  vnet_address_space = var.vnet_address_space

  depends_on = [ module.ResourceGroup]
}

module "virtualMachin" {
  source = "../modules/virtualMachin"
  VM_resource_group_name = module.ResourceGroup.resource_group_name
  VM_location = module.ResourceGroup.resource_group_location
  VM_count = local.variables_data.VM_count
  VM_size = local.variables_data.VM_size
  os_version = local.variables_data.os_version
  os_disk_type = local.variables_data.os_disk_type
  virtual_network_name = module.virtualNetwork.virtual_network_name
  vmSubnet_address_space = var.vmSubnet_address_space
  key_vault_id = module.keyVault.key_vault_id

  depends_on = [
    module.ResourceGroup, module.virtualNetwork, module.keyVault
  ]
}

module "AppdVM" {
  source = "../modules/AppdVM"
  AppdVm_resource_group_name = module.ResourceGroup.resource_group_name
  AppdVm_location = module.ResourceGroup.resource_group_location
  AppdVm_size = local.variables_data.AppdVm_size
  #AppdVm_os_version = local.variables_data.AppdOs_version
  #os_disk_type = local.variables_data.os_disk_type
  AppdVm_virtual_network_name = module.virtualNetwork.virtual_network_name
  AppdVm_Subnet_address_space = var.AppdVMSubnet_address_space
  key_vault_id = module.keyVault.key_vault_id

  depends_on = [
    module.ResourceGroup, module.virtualNetwork, module.keyVault
  ]
}

module "AKScluster" {
  source = "../modules/AKScluster"
  AKS_resource_group_name = module.ResourceGroup.resource_group_name
  AKS_location = module.ResourceGroup.resource_group_location
  AKS_version = local.variables_data.AKS_version
  AKS_node_size = local.variables_data.AKS_node_size
  client_id = var.client_id
  client_secret = var.client_secret
  virtual_network_name = module.virtualNetwork.virtual_network_name
  pub_key = var.pub_key
  aksSubnet_address_space = var.aksSubnet_address_space

  depends_on = [
    module.ResourceGroup, module.virtualNetwork
  ]

}

module "applicationGateway" {
  source = "../modules/applicationGateway"
  agw_resource_group_name = module.ResourceGroup.resource_group_name
  agw_location = module.ResourceGroup.resource_group_location
  agw_virtual_network = module.virtualNetwork.virtual_network_name
  keyvault_ssl_dev = var.keyvault_ssl_dev
  agwSubnet_address_space = var.agwSubnet_address_space
  identidy_ids = var.identidy_ids
  ssl_certificate_name = var.ssl_certificate_name

  depends_on = [
    module.ResourceGroup, module.virtualNetwork
  ]
}

module "mysqlServer" {
  source = "../modules/mysqlServer"
  mysql_resource_group_name = module.ResourceGroup.resource_group_name
  mysql_resource_group_location = module.ResourceGroup.resource_group_location
  mysql_sku_name = local.variables_data.mysql_sku_name
  mysql_storage_gb = local.variables_data.mysql_storage_gb
  mysql_version = local.variables_data.mysql_version
  key_vault_id = module.keyVault.key_vault_id
  depends_on = [
  module.ResourceGroup, module.virtualNetwork, module.keyVault
  ]
}

module "HDInsightCluster" {
  source = "../modules/HDInsightCluster"
  kaf_cluster_name = "kaf-${module.ResourceGroup.resource_group_name}"
  kaf_resource_group_name = module.ResourceGroup.resource_group_name
  kaf_resource_group_location = module.ResourceGroup.resource_group_location
  kaf_storage_account_name = "stgkaf${replace(module.ResourceGroup.resource_group_name,"-","")}"
  kaf_container_name = "kaf-${module.ResourceGroup.resource_group_name}"
  kaf_virtual_network = module.virtualNetwork.virtual_network_name
  kaf_virtual_network_id = module.virtualNetwork.virtual_network_id
  kafSubnet_address_space = var.kafSubnet_address_space
  key_vault_id = module.keyVault.key_vault_id

  depends_on = [
  module.ResourceGroup, module.virtualNetwork, module.keyVault
  ]
}

module "azureMapsAccount" {
  source = "../modules/azureMapsAccount"
  amp_resource_group_name = module.ResourceGroup.resource_group_name

  depends_on = [ module.ResourceGroup]
}

