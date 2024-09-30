variable "ResourceGroup_name" {
  type = string
  description = "Resource Group name"
}

variable "ResourceGroup_location" {
  type = string
  description = "Resource Group location"
}

# variable "create_storage_account" {
#     type = bool
# }

variable "create_resource_group" {
  type = bool
}

# variable "create_cdn_endpoint" {
#   type = bool
# }

variable "Cost_Center_ID" {
  type = string
}

variable "Environment_Type" {
  type = string
}

variable "customer_type" {
  type = string
}

variable "Product_Group" {
  type = string
}

variable "Customer" {
  type = string
}

variable "Owner" {
  type = string
}

variable "VM_count" {
  type = string
}

variable "VM_size" {
  type = string
  description = "VM size"
}

variable "os_version" {
  type = string
}

variable "os_disk_type" {
  type = string
}

variable "AppdVm_size" {
  type = string
  description = "AppD VM size"
}

# variable "AppdOs_version" {
#   type = string
# }


variable "AKS_node_size" {
  type = string
}

variable "AKS_version" {
  type = string
}

variable "mysql_sku_name" {
  type = string
}

variable "mysql_storage_gb" {
  type = string
}

variable "pub_key" {
  type = string 
}

variable "keyvault_ssl_dev" {
    type = string
}

variable "ssl_certificate_name" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "vnet_address_space" {
  type = string
}

variable "vmSubnet_address_space" {
  type = string
}

variable "AppdVMSubnet_address_space" {
  type = string
}

variable "kafSubnet_address_space" {
  type = string
}

variable "aksSubnet_address_space" {
  type = string
}

variable "agwSubnet_address_space" {
  type = string
}

variable "identidy_ids" {
  type = string
}