

resource "azurerm_network_interface" "nic" {
  count = var.number_of_servers

  name                = azurecaf_name.per_instance[count.index].results["azurerm_network_interface"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "example" {
  count = var.number_of_servers

  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
}

resource "azurerm_windows_virtual_machine" "vm" {
  count = var.number_of_servers

  name                = azurecaf_name.per_instance[count.index].result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = var.vm_userid
  admin_password      = var.vm_password
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  availability_set_id = azurerm_availability_set.aset.id
}
