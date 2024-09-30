variable "agw_resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "agw_location" {
    type = string
    description = "location of deployement"
}

variable "agw_virtual_network" {
    type = string
}

variable "keyvault_ssl_dev" {
    type = string  
}

variable "identidy_ids" {
  type = string
}

variable "agwSubnet_address_space" {
  type = string
}

variable "ssl_certificate_name" {
  type = string
}