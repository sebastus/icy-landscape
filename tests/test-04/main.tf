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

resource "azurerm_virtual_network" "network" {
  name                     = "vnet"
  resource_group_name      = "rg-succeed"
  location                 = "uksouth"
  address_space            = [ "10.0.0.0/16" ]
}
