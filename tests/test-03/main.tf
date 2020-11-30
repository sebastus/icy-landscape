########PROVIDERS#########
terraform {
  required_version = ">= 0.13"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.35.0"
    }

    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.1.5"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_storage_account" "storage" {
  name                     = "abc123golivestorage"
  resource_group_name      = "rg-succeed"
  location                 = "uksouth"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
