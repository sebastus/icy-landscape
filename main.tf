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

variable "definition_management_group" {
  type    = string
  default = "golive"
}

#
# Adds policy definitions for all Azure resource types that support diagnostic settings
# Adds a policy initiative that contains those policies
#
module "diagnostic_policies" {
  source                = "github.com/Nepomuceno/terraform-azurerm-monitoring-policies.git?ref=main"
  name                  = "DiagnosticsInitiative"
  management_group_name = var.definition_management_group
}

