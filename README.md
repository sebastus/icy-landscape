# icy-landscape

Terraform and Go code for blog series

## Repo contents

- .devcontainer: the repo was built using VS Code. The devcontainer has the required tools. Use the devcontainer, or use the source as documentation on tool versions.
- scenarios: Azure infrastructure scenarios demonstrating the use of AzureCAF for naming resources.
- tests: Terratest tests used for demonstrating how to parallelize execution of golang tests
- root: .env.template and main.tf used to build out scenario and test contextual framework. Also a few notes helpful to using the repo.

A common requirement for all scenarios and tests is a terraform module encapsulated in a [Git repo](https://github.com/Nepomuceno/terraform-azurerm-monitoring-policies). This module defines diagnostic policies for many Azure resource types as well as a single encompassing diagnostic initiative (aka policy set).  

## How to use the repo

- apply main.tf in root folder. this adds the DiagnosticsInitiative policy initiative and its policies as definitions to the management group
- no initiative or policy assignments are created. this is done by the main.tf in the tests or scenarios folder. Search the repo for "azurerm_policy_assignment" to see a list.
- from tests folder command line, run "gotestsum --format standard-verbose -- -timeout=30m -parallel 5"

namePrecedence := []string{"name", "slug", "random", "suffixes", "prefixes"}
