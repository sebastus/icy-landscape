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

# Current Subscription as a data Source
data "azurerm_subscription" "current" {}

# get the diagnostics initiative
data "azurerm_policy_set_definition" "DiagnosticsInitiative" {
  display_name = "DiagnosticsInitiative"
}

resource "azurecaf_name" "rg_name" {
  resource_type = "azurerm_resource_group"

  random_length = 8
}
resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.rg_name.result
  location = "uksouth"
}
output "rgname" {
  value = azurecaf_name.rg_name.result
}

# name resource definition: https://github.com/aztfmod/terraform-provider-azurecaf/blob/91e647bde30df9248b798a75b9ad86e8d6544851/resourceDefinition.json#L1750
resource "azurecaf_name" "ws_name" {
  resource_type = "azurerm_log_analytics_workspace"

  random_length = 8
  suffixes      = ["local"]
  name          = substr(data.azurerm_subscription.current.display_name, 0, 45)

  # desired outcome = log-<sub name>-xxxxxxxx-local
  # length = 2 + 1 + (45) + 1 + 8 + 1 + 5 = max of 63 characters for log analytics workspace name
  # 45 is the max # of chars to get from the subscription name in order to get everything else into the generated name
  # because the "name" parameter is an override, if more characters are used, other portions of the generated name will be truncated
}
resource "azurerm_log_analytics_workspace" "ws" {
  name                = azurecaf_name.ws_name.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
output "wsname" {
  value = azurecaf_name.ws_name.result
}

# name resource definition: https://github.com/aztfmod/terraform-provider-azurecaf/blob/b1434295334e709d0163a1a1ee083479c51cfe20/resourceDefinition.json#L1491
resource "azurecaf_name" "sa_name" {
  resource_type = "azurerm_storage_account"

  random_length = 8
  suffixes      = ["local"]
  name          = substr(data.azurerm_subscription.current.display_name, 0, 9)

  # desired outcome = sa<sub name>xxxxxxxxlocal
  # length = 2 + (9) + 8 + 5 = max of 24 characters for storage account name
  # 9 is the max # of chars to get from the subscription name in order to get everything else into the generated name
  # because the "name" parameter is an override, if more characters are used, other portions of the generated name will be truncated
}
resource "azurerm_storage_account" "storage" {
  name                     = azurecaf_name.sa_name.result
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
output "saname" {
  value = azurecaf_name.sa_name.result
}

resource "azurerm_policy_assignment" "diagnostics_initiative" {
  name                 = "diagnostics-initiative-assignment"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = data.azurerm_policy_set_definition.DiagnosticsInitiative.id
  description          = "Policy Assignment created via terraform"
  display_name         = "Unit test diagnostic Logs application"
  identity {
    type = "SystemAssigned"
  }
  location = "uksouth"

  metadata   = <<METADATA
    {
    "category": "Logs"
    }
METADATA
  parameters = <<PARAMETERS
{
  "workspaceId": {
    "value": "${azurerm_log_analytics_workspace.ws.id}"
  },
  "storageAccountName": {
    "value": "${azurerm_storage_account.storage.name}"
  }
}
PARAMETERS
}

resource "azurerm_role_assignment" "contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "contributor"
  principal_id         = azurerm_policy_assignment.diagnostics_initiative.identity[0].principal_id
}
