# configure Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.84.0"
    }
  }
}

provider "azurerm" {
  features{}
}

# configure Resource Blocks

# Create resource Groups
resource "azurerm_resource_group" "Ubuntu_group"{
 name = "Ubuntu20.04-4363"
 location = " eastus"
}
#create a Virtual Network
resource "azurerm_virtual_network" "U_4363"{
  name = "U_4363"
  address_space = ["10.0.0.0/24"]
  location = azurerm_resource_group.Ubuntu_group.location
  resource_group_name = azurerm_resource_group.Ubuntu_group.name

}

# Create public IP address
resource "azurerm_public_ip" "Ubuntu_group_publicIP" {
  name                = "Ubuntu_group_Pub_IP"
  resource_group_name = azurerm_resource_group.Ubuntu_group.name
  location            = azurerm_resource_group.Ubuntu_group.location
  allocation_method   = "Static"  # Change to "Static" for a static public IP
}

# create a subnet
resource "azurerm_subnet" "Ubuntu_group" {
  name = "Ubuntu_group_subnet"
  virtual_network_name = azurerm_virtual_network.U_4363.name
  resource_group_name = azurerm_resource_group.Ubuntu_group.name
  address_prefixes = ["10.0.0.0/24"]

}

# create an NIC
resource "azurerm_network_interface" "Ubuntu_group" {
  
  # count               = 3  # number of NICs
  name                = "Ubuntu_Group_NIC"
  location            = azurerm_resource_group.Ubuntu_group.location
  resource_group_name = azurerm_resource_group.Ubuntu_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Ubuntu_group.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Ubuntu_group_publicIP.id

  }
}

# Create the Ubuntu VM
resource "azurerm_linux_virtual_machine" "Ubuntu_group" {
  
  # count               = 3  # number of VMs
  name                = "Ubuntu20.04-4363"
  resource_group_name = azurerm_resource_group.Ubuntu_group.name
  location            = azurerm_resource_group.Ubuntu_group.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"
  admin_password      = "Password1234!"
  disable_password_authentication = false


  network_interface_ids = [
    azurerm_network_interface.Ubuntu_group.id,
  ]
 

  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

 
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "20.04.202209200"
  }
}


