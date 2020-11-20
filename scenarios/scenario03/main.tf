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

variable "number_of_servers" {
  type    = number
  default = 2
}

resource "azurecaf_name" "singles" {
  resource_type  = "azurerm_resource_group"
  resource_types = ["azurerm_virtual_network", "azurerm_availability_set", "azurerm_subnet", "azurerm_lb", "azurerm_public_ip"]
  random_length  = 4
}

resource "azurecaf_name" "per_instance" {
  count = var.number_of_servers

  resource_type  = "azurerm_windows_virtual_machine"
  resource_types = ["azurerm_network_interface"]

  name          = "websvr"
  random_length = 4

}

output "rgname" {
  value = azurecaf_name.singles.result
}
output "singles" {
  value = azurecaf_name.singles.results
}

output "vm_names" {
  value = azurecaf_name.per_instance.*.result
}
output "per_instance" {
  value = azurecaf_name.per_instance.*.results
}

