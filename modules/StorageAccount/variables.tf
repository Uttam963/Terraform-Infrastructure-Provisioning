variable "storage_account_name" {
    type = string
    description = "base name for storage account"
}

variable "storage_account_resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "storage_account_location" {
    type = string
    description = "location of deployement"
}

# variable "create_storage_account" {
#     type = bool
# }

# variable "common_tags" {
#   type = map(string)
# }