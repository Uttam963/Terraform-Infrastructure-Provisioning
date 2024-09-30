variable "AKS_resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "AKS_location" {
    type = string
    description = "location of deployement"
}

variable "client_id" {
  type = string
  description = "client id"
}

variable "client_secret" {
  type = string
  description = "client secret"
}

variable "AKS_node_size" {
  type = string
}

variable "AKS_version" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "pub_key" {
  type = string
}

variable "aksSubnet_address_space" {
  type = string
}

