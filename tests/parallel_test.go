package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestParallel(t *testing.T) {
	// setup
	options := &terraform.Options{
		TerraformDir: ".",
	}
	terraform.InitAndApply(t, options)
	defer terraform.Destroy(t, options)

	t.Run("group", func(t *testing.T) {
		t.Run("terraform_init_should_succeed", func(t *testing.T) {
			t.Parallel()
			terraformTestOptions := &terraform.Options{
				TerraformDir: "./test-01",
			}
			defer terraform.Destroy(t, terraformTestOptions)
			terraform.Init(t, terraformTestOptions)
			if _, err := terraform.ApplyE(t, terraformTestOptions); err != nil {
				t.Fatalf("Should be no errors in trivial TF.")
			}
		})

		t.Run("create_rg_should_fail", func(t *testing.T) {
			t.Parallel()
			terraformTestOptions := &terraform.Options{
				TerraformDir: "./test-02",
			}
			defer terraform.Destroy(t, terraformTestOptions)
			terraform.Init(t, terraformTestOptions)
			if _, err := terraform.ApplyE(t, terraformTestOptions); err == nil {
				t.Fatalf("Should not be possible to create rg of same name.")
			}
		})

		t.Run("create_storage_should_succeed", func(t *testing.T) {
			t.Parallel()
			terraformTestOptions := &terraform.Options{
				TerraformDir: "./test-03",
			}
			defer terraform.Destroy(t, terraformTestOptions)
			terraform.Init(t, terraformTestOptions)
			if _, err := terraform.ApplyE(t, terraformTestOptions); err != nil {
				t.Fatalf("Should be possible to create storage.")
			}
		})

		t.Run("create_virtual_network_should_succeed", func(t *testing.T) {
			t.Parallel()
			terraformTestOptions := &terraform.Options{
				TerraformDir: "./test-04",
			}
			defer terraform.Destroy(t, terraformTestOptions)
			terraform.Init(t, terraformTestOptions)
			if _, err := terraform.ApplyE(t, terraformTestOptions); err != nil {
				t.Fatalf("Should be possible to create virtual network.")
			}
		})

		t.Run("create_public_ip_should_succeed", func(t *testing.T) {
			t.Parallel()
			terraformTestOptions := &terraform.Options{
				TerraformDir: "./test-05",
			}
			defer terraform.Destroy(t, terraformTestOptions)
			terraform.Init(t, terraformTestOptions)
			if _, err := terraform.ApplyE(t, terraformTestOptions); err != nil {
				t.Fatalf("Should be possible to create public ip.")
			}
		})
	})

}
