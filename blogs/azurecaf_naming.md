---
title: Standardize resource names in Terraform scripts
published: false
description: Use a tool to generate Azure resource names in your Terraform script - how and why.
tags: azure,tooling,devops,cloud
series: DevCrewLever-Fall2020
//cover_image: https://direct_url_to_image.jpg
---

When starting a Terraform project for an Azure architecture, it's easy to come up with useful names for the resources in your architecture. They usually look like "my-resource-group', "my-public-ip", "my-vm", "mystorageaccount", and so on. When the architecture grows, or elements of it scale out, it becomes harder to design useful names that meet all requirements. This blog is about a tool that helps with this task.  

If you agree with the above and just want a link to the tool, here it is: [terraform-provider-azurecaf](https://github.com/aztfmod/terraform-provider-azurecaf).  
Usage samples are fully implemented in the [scenarios folder](https://github.com/sebastus/icy-landscape/tree/main/scenarios) of the [github repo](https://github.com/sebastus/icy-landscape).  

Everyone else, read on.  

### Requirements that must be met

* for each resource type, rules vary
  * length
  * accepted characters
  * accepted patterns (e.g. first character must be a lowercase alpha)
* It must be possible to override generated names in special cases
* It must be possible to generate globally unique names
* Generated names must behave like any other resource in tfstate
  * names persist across 'terraform apply' runs as long as name resource definition remains the same
  * name resources can be destroyed, tainted, etc just like any other terraform resource

### Additional nice-to-have features

* a generated name should conform to a regular pattern that becomes familiar and instantly recognizable
* when there are many resources in list, it should be possible to instantly recognize resource types from the name
* clear and concise name generation code
* when an architecture grows or resources scale out horizontally, name generation follows naturally
* when testing permutations of resource properties, generating names is a very powerful enabling technique

### Solution to the problem

The solution is a Terraform provider that generates resource names. Unsurprisingly, it meets all of the conditions above. Generated resource name configuration options include (in order of precedence):

* name - overrides other options
* slug - a few characters denoting the resource type
* random - randomly generated chars
* suffixes - an array of suffixes that are appended
* prefixes - an array of prefixes that are pre-pended

All configuration options are defined in the [provider repo](https://github.com/aztfmod/terraform-provider-azurecaf).

The following examples are fully implemented in the [scenarios folder](https://github.com/sebastus/icy-landscape/tree/main/scenarios) of the [github repo](https://github.com/sebastus/icy-landscape).

#### Generates and implements a resource group name similar to rg-xxxxxxxx (very simple example)

```terraform
resource "azurecaf_name" "rg_name" {
  resource_type = "azurerm_resource_group"

  random_length = 8
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.rg_name.result
  location = "uksouth"
}
```

#### Generates and implements a log analytics workspace name (example of name override)

```terraform
resource "azurecaf_name" "ws_name" {
  resource_type = "azurerm_log_analytics_workspace"

  random_length = 8
  suffixes      = ["local"]
  name          = substr(data.azurerm_subscription.current.display_name, 0, 44)

  # desired outcome = log-<sub name>-xxxxxxxx-local
  # length = 3 + 1 + (44) + 1 + 8 + 1 + 5 = max of 63 characters for log analytics workspace name
  # 44 is the max # of chars to get from the subscription name in order to get everything else into the generated name
  # because the "name" parameter is an override, if more characters are used, other portions of the generated name will be truncated
}

resource "azurerm_log_analytics_workspace" "ws" {
  name                = azurecaf_name.ws_name.result
  
  ...
}

```
The resource name rules (such as the max length of 63 characters) for azurerm_log_analytics_workspace are in [this file](https://github.com/aztfmod/terraform-provider-azurecaf/blob/3b5b52b487acf1c338257ced78fe587e2d315029/resourceDefinition.json#L1760).  

#### Generates multiple singleton names with a single azurecaf_name resource

```terraform
resource "azurecaf_name" "names" {
  resource_type  = "azurerm_resource_group"
  resource_types = ["azurerm_lb", "azurerm_public_ip"]
  random_length  = 4
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.names.result
  location = "uksouth"
}

resource "azurerm_public_ip" "pip" {
  name                = azurecaf_name.names.results["azurerm_public_ip"]
  
  ...
}

resource "azurerm_lb" "lb" {
  name                = azurecaf_name.names.results["azurerm_lb"]
  
  ...
}
```

#### Generates a set of names per vm instance of a cluster of vms

```terraform
resource "azurecaf_name" "per_instance" {
  count = var.number_of_servers

  resource_type  = "azurerm_windows_virtual_machine"
  resource_types = ["azurerm_network_interface"]

  name          = "websvr"
  random_length = 4

}

resource "azurerm_network_interface" "nic" {
  count = var.number_of_servers

  name                = azurecaf_name.per_instance[count.index].results["azurerm_network_interface"]
  
  ...
}

resource "azurerm_network_interface_backend_address_pool_association" "example" {
  count = var.number_of_servers

  network_interface_id    = azurerm_network_interface.nic[count.index].id
  
  ...
}

resource "azurerm_windows_virtual_machine" "vm" {
  count = var.number_of_servers

  name                = azurecaf_name.per_instance[count.index].result
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  ...
}

```
