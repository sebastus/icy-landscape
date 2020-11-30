# Azure policy, resource naming, parallel Terratest

Terraform and Go code for blog series

## Repo contents

- .devcontainer: the repo was built using VS Code. The [devcontainer](https://code.visualstudio.com/docs/remote/containers) has the required tools. Use the devcontainer, or use the source as documentation on tool versions.
- scenarios: Azure infrastructure scenarios demonstrating the use of [AzureCAF](https://github.com/aztfmod/terraform-provider-azurecaf) for naming resources.
- tests: [Terratest](https://github.com/gruntwork-io/terratest) tests used for demonstrating how to parallelize execution of golang tests
- root: .env.template and main.tf used to build out scenario and test contextual framework. Also a few notes helpful to using the repo.

A common requirement for all scenarios and tests is a terraform module encapsulated in a [Git repo](https://github.com/Nepomuceno/terraform-azurerm-monitoring-policies). This module defines diagnostic policies for many Azure resource types as well as a single encompassing diagnostic initiative (aka policy set).  

## How to use the repo

- The basic idea is this:
  - a set of policies is defined in an Azure Management Group.
  - The policy initiative is assigned to an Azure subscription in the management group so that resources in that subscription are affected by the policies in the initiative.
  - Various scenarios and tests are run against that backdrop.
- terraform apply the root folder. this adds the DiagnosticsInitiative policy initiative and its policies as definitions to the [management group](https://docs.microsoft.com/en-us/azure/governance/management-groups/)
- no initiative or policy assignments are created. this is done by the scripts in the tests or scenarios folders. Search the repo for "azurerm_policy_assignment" to see a list.
- The scenarios are additive, which is to say, apply scenario 1 to build context. Scenarios 2 & 3 build on 1, but individually. Terraform destroy after 2 or 3 before running the other. Terraform destroy 1 if you want to run the tests, and vice versa.
- from tests folder command line, run "gotestsum --format standard-verbose -- -timeout=30m -parallel 5"

### Dependencies

- Scenario 2 depends on Scenario 1
- Scenario 3 depends on Scenario 1
- Tests-01 to 05 depend on the script in the tests folder. But the Terratest handles these dependencies correctly.

namePrecedence := []string{"name", "slug", "random", "suffixes", "prefixes"}
