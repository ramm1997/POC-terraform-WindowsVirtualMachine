provider "azurerm" {
  # Configuration options
   features {}
}

resource "azurerm_resource_group" "ResourceGroup-POC-RG" {
  name     = "poc-resources"
  location = "eastus"
  tags = {
    Owner = "ramm"
  }
}

resource "azurerm_virtual_network" "VirtualNetwork" {
  name                = "POC-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.ResourceGroup-POC-RG.location
  resource_group_name = azurerm_resource_group.ResourceGroup-POC-RG.name
}

resource "azurerm_subnet" "POC-subnet" {
  name                 = "Subnet-internal"
  resource_group_name  = azurerm_resource_group.ResourceGroup-POC-RG.name
  virtual_network_name = azurerm_virtual_network.VirtualNetwork.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "NetworkInterface" {
  name                = "POC-nic"
  location            = azurerm_resource_group.ResourceGroup-POC-RG.location
  resource_group_name = azurerm_resource_group.ResourceGroup-POC-RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.POC-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "WindowsVirtualMachine" {
  name                = "Windows-machine"
  resource_group_name = azurerm_resource_group.ResourceGroup-POC-RG.name
  location            = azurerm_resource_group.ResourceGroup-POC-RG.location
  size                = "Standard_F2"
  admin_username      = "adminterraformpoc"
  admin_password      = "admin@123456789"
  network_interface_ids = [
    azurerm_network_interface.NetworkInterface.id,
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
}