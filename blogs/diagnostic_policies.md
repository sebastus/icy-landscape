---
title: Auto-start collection of Azure diagnostic telemetry
published: true
description: How to automatically configure Azure Monitor diagnostic profiles on Azure resources using Azure Policy and Terraform, thus initiating collection of logs and metrics.
tags: azure,monitor,devops,terraform
series: DevCrewLever-Fall2020
---
_This blog resulted from a customer development engagement. Want to read related blogs?  [Secure Azure as Code](https://dev.to/cse/secure-azure-as-code-5d9i)_

Infrastructure and platform monitoring are the province of [Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/). The documentation provides several ways to configure diagnostic profiles on your resources so that the telemetry flows, but doing it onesy-twosy is a tax. Using [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/) together with an [open source Terraform module](https://github.com/Nepomuceno/terraform-azurerm-monitoring-policies) allows this task to fade into the background - done and dusted.

### Define policies and policy initiative in the management group

```terraform
module "diagnostic_policies" {
  source                = "github.com/Nepomuceno/terraform-azurerm-monitoring-policies.git?ref=main"
  name                  = "DiagnosticsInitiative"
  management_group_name = var.definition_management_group
}
```

The Terraform script in the root folder of the [github repo]((https://github.com/sebastus/icy-landscape)) fully implements this step.  

### Assign policy initiative to your subscription

```terraform
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
```

### Give the SystemAssigned identity defined above rights to remediate

```terraform
resource "azurerm_role_assignment" "contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "contributor"
  principal_id         = azurerm_policy_assignment.diagnostics_initiative.identity[0].principal_id
}
```

Scenario 01 in [the scenarios folder](https://github.com/sebastus/icy-landscape/tree/main/scenarios) fully implements these steps. Test by using a subscription that already has resources in it that do not have diagnostic profile(s) defined, or create new resources after running the above. Scenarios 02 and 03 are provided for convenience. They are dependent on scenario 01, so run scenario 01 first, then 02 or 03, etc.

### Explanation and Background

Azure Monitor diagnostic profiles tell the platform what information you want to collect and where to send it. "What information you want to collect" is different for each resource type and there is no "everything" button. And that's the rub - one must make decisions for each resource in the system architecture. Using the module makes it possible to encapsulate all of this into one easy step in the Terraform script.

A project frequently equates to an Azure subscription, and there are usually multiple projects within an organization. Managing the resources in these projects is made more convenient through the use of [Management Group](https://docs.microsoft.com/en-us/azure/governance/management-groups/) and [Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/). From [this page](https://docs.microsoft.com/en-us/azure/governance/management-groups/overview):  

*Azure management groups provide a level of scope above subscriptions. You organize subscriptions into containers called "management groups" and apply your governance conditions to the management groups. All subscriptions within a management group automatically inherit the conditions applied to the management group. Management groups give you enterprise-grade management at a large scale no matter what type of subscriptions you might have. All subscriptions within a single management group must trust the same Azure Active Directory tenant.*

Using the module, many Azure policies and a policy initiative are defined (usually) at the management group level. Because each project team monitors their own infrastructure and each diagnostic profile designates the destination of the telemetry, it's best to assign the policy initiative at the subscription level. This allows the telemetry collection point to be within that subscription. It is possible to create multiple diagnostic profiles per resource so that telemetry can be directed to a global management point if desired.

Each policy defined by the module targets a resource type, such as network security group, virtual machine, network interface card, and so on. If a resource does not meet the requirements of the policy, a remediation task creates the diagnostic profile for the resource. When the module is assigned to the subscription (via terraform apply) the results are not instantaneous - the Azure policy engine may take up to 15 minutes to scan resources and run remediation tasks.
