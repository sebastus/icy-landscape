resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.singles.result
  location = "uksouth"
}

resource "azurerm_public_ip" "pip" {
  name                = azurecaf_name.singles.results["azurerm_public_ip"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = azurecaf_name.singles.results["azurerm_lb"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "pip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "pool" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "backend_pool"
}

resource "azurerm_virtual_network" "vnet" {
  name                = azurecaf_name.singles.results["azurerm_virtual_network"]
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = azurecaf_name.singles.results["azurerm_subnet"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_availability_set" "aset" {
  name                        = azurecaf_name.singles.results["azurerm_availability_set"]
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  platform_fault_domain_count = 2
}