variable "vnet_resource_group_name" {
  description = "The prefix which should be used for all resources in this example"
  default="bynet-apac-test-01"
}

variable "vnet_resource_group_location" {
  description = "The Azure Region in which all resources in this example should be created."
  default="southeastasia"
}

variable "vnet_address_space" {
  type = string
}