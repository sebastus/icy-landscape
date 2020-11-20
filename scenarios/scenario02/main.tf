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

resource "azurecaf_name" "names" {
  resource_type  = "azurerm_resource_group"
  resource_types = ["azurerm_lb", "azurerm_public_ip"]
  random_length  = 4
}

output "rgname" {
  value = azurecaf_name.names.result
}
output "names" {
  value = azurecaf_name.names.results
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.names.result
  location = "uksouth"
}

resource "azurerm_public_ip" "pip" {
  name                = azurecaf_name.names.results["azurerm_public_ip"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = azurecaf_name.names.results["azurerm_lb"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "pip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}
