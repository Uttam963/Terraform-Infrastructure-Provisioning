variable "AppdVm_resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "AppdVm_location" {
    type = string
    description = "location of deployement"
}

variable "AppdVm_size" {
  type = string
  description = "VM size"
}

# variable "AppdVm_os_version" {
#   type = string
# }

# variable "AppdVm_os_disk_type" {
#   type = string
# }

variable "AppdVm_virtual_network_name" {
  type = string
}

variable "AppdVm_Subnet_address_space" {
  type = string
}

variable "key_vault_id" {
  type = string
}
