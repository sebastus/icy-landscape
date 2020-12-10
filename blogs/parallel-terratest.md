---
title: Test your Azure policies in parallel
published: true
description: How to run Terratest in parallel across all Azure policies assigned in your environment
tags: azure,golang,devops,terraform
series: DevCrewLever-Fall2020
---
_This blog resulted from a customer development engagement. Want to read related blogs?  [Secure Azure as Code](https://dev.to/cse/secure-azure-as-code-5d9i)_

Testing a policy is done with a few steps, each of which is a Terraform script:

* Test the positive case, where the bad outcome the policy protects against is not challenged
* Test the negative case, where the bad outcome is attempted (and hopefully audited or denied)
* Both create and update use cases

If each test case requires creating a few Azure resources, the time to run these tests one after the other grows rapidly, especially in the case of testing policies. Having >100 policies to test is not unusual. Also, policies are normally defined at the management group level. This step can be done independently of the tests to set the context. Running the tests probably starts out by assigning policies to the test environment - a lower level management group or a subscription. Then the individual tests run on that test environment before it's reset with "terraform destroy".

### Define policies and policy initiative in the management group

```terraform
module "diagnostic_policies" {
  source                = "github.com/Nepomuceno/terraform-azurerm-monitoring-policies.git?ref=main"
  name                  = "DiagnosticsInitiative"
  management_group_name = var.definition_management_group
}
```

The Terraform script in the root folder of the [github repo](https://github.com/sebastus/icy-landscape) fully implements this step. It's done once before running any tests.

### Run tests

In the tests folder of the [github repo](https://github.com/sebastus/icy-landscape) there are two approaches to this. One is implemented serially, the other in parallel. Both run the Terraform in the tests folder to do the policy assignment to the test environment. It also creates a couple of resources to use during tests that will follow.

#### Serial

```golang
func TestSerial(t *testing.T) {
    // setup the environment by assigning policy to the subscription
    options := &terraform.Options{
        TerraformDir: ".",
    }
    terraform.InitAndApply(t, options)
    defer terraform.Destroy(t, options)

    // run the first test
    t.Run("terraform_init_should_succeed", func(t *testing.T) {
        terraformTestOptions := &terraform.Options{
            TerraformDir: "./test-01",
    ... // and so on
```

#### Parallel

```golang
func TestParallel(t *testing.T) {
    // setup the environment by assigning policy to the subscription
    options := &terraform.Options{
        TerraformDir: ".",
    }
    terraform.InitAndApply(t, options)
    defer terraform.Destroy(t, options)

    t.Run("group", func(t *testing.T) {                 // <-- group the tests
        t.Run("terraform_init_should_succeed", func(t *testing.T) {
            t.Parallel()                                // <-- invoke Parallel()
            terraformTestOptions := &terraform.Options{
                TerraformDir: "./test-01",
    ... // and so on
```
