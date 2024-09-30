terraform {
  required_version = ">= 0.15"
}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.50.0"
    }
  }
}

provider "azurerm" {
  subscription_id = ""
  tenant_id       = ""

  features {
  }
}