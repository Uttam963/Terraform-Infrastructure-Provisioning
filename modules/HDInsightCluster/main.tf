resource "random_password" "HDI_Ambari_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "hdi_Ambari_password" {
  name         = "hdi-Ambari-password"
  value        = random_password.HDI_Ambari_password.result
  key_vault_id = var.key_vault_id
}

resource "random_password" "HDI_ssh_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 1
  min_upper        = 1
  numeric          = true
  min_numeric      = 1
}

resource "azurerm_key_vault_secret" "hdi_ssh_password" {
  name         = "hdi-ssh-password"
  value        = random_password.HDI_ssh_password.result
  key_vault_id = var.key_vault_id
}


resource "azurerm_subnet" "azsubnetkaf" {
  name                 = "snt-${var.kaf_resource_group_name}-hdi"
  resource_group_name  = var.kaf_resource_group_name
  virtual_network_name = var.kaf_virtual_network
  address_prefixes     = ["${var.kafSubnet_address_space}"]
}

resource "azurerm_storage_account" "kafkastorage" {
  name                     = "${replace(var.kaf_resource_group_name, "-", "")}hdistg"
  resource_group_name      = var.kaf_resource_group_name
  location                 = var.kaf_resource_group_location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "kafkacontainer" {
  name                  = "hdi-${var.kaf_resource_group_name}"
  storage_account_name  = azurerm_storage_account.kafkastorage.name
  container_access_type = "private"

}

resource "azurerm_hdinsight_kafka_cluster" "azkafka" {
  name                = "hdi-${var.kaf_resource_group_name}"
  resource_group_name = var.kaf_resource_group_name
  location            = var.kaf_resource_group_location
  cluster_version     = "5.1"
  tier                = "Standard"
  component_version {
    kafka = 3.2
  }

  gateway {
    username = "cicdadmin"
    password = random_password.HDI_Ambari_password.result
  }
  storage_account {
    storage_container_id = azurerm_storage_container.kafkacontainer.id
    storage_account_key  = azurerm_storage_account.kafkastorage.primary_access_key
    is_default           = "true"
  }
  roles {
    head_node {
      vm_size            = "Standard_D3_V2"
      username           = "cicdadminssh"
      password           = random_password.HDI_ssh_password.result
      virtual_network_id = var.kaf_virtual_network_id
      subnet_id          = azurerm_subnet.azsubnetkaf.id
    }
    worker_node {
      vm_size                  = "Standard_D3_V2"
      target_instance_count    = 4
      number_of_disks_per_node = 4
      username                 = "cicdadminssh"
      password                 = random_password.HDI_ssh_password.result
    }
    zookeeper_node {
      vm_size            = "Standard_D3_V2"
      username           = "cicdadminssh"
      password           = random_password.HDI_ssh_password.result
      virtual_network_id = var.kaf_virtual_network_id
      subnet_id          = azurerm_subnet.azsubnetkaf.id
    }
  }
}