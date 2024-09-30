variable "ResourceGroup_name" {
  type = string
  description = "base name for storage acount and cdn endpoint"
}

variable "ResourceGroup_location" {
    type = string
    description = "The location for deployment"
    default = "East US"
}

variable "create_resource_group" {
  type = bool
}

variable "Cost_Center_ID" {
  type = string
}

variable "Environment_Type" {
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

