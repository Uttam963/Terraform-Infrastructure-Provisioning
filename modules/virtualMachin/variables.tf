variable "VM_resource_group_name" {
    type = string
    description = "Name of the resource group"
}

variable "VM_location" {
    type = string
    description = "location of deployement"
}

variable "VM_count" {
    type = string
    description = "Number of VMs to create"
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

variable "virtual_network_name" {
  type = string
}

variable "vmSubnet_address_space" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable setupelasticfile {
  type=string
  default = "install_elasticsearch.sh"
}

