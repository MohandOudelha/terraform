terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~>2.0"
        }
    }
}

provider "azurerm" {
    features {}

        subscription_id = "<azure_subscription_id>"
        tenant_id = "<azure_subscription_tenant_id>"
        client_id = "<service_principal_appid>"
        client_secret = "<service_principal_password>"
    }

##Resource Group
resource "azurerm_resource_group" "rg" {
name = "TerraformRg"
location = "france central"
}

##Avaibility Set
resource "azurerm_availability_set" "DemoAset" {
    name = "tf-aset"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

##Virtual Network
resource "azurerm_virtual_network" "vnet" {
    name = "tf-vNet"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

##Subnet
resource "azurerm_subnet" "subnet" {
    name = "Internal"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = ["10.0.2.0/24"]
}

##Network interface
resource "azurerm_network_interface" "example" {
    name = "tf-vmwin-nic"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name = "internal"
        subnet_id = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}

##Azure Virtual Machine
resource "azurerm_windows_virtual_machine" "example" {
    name = "tf-vmwin"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_F2"
    admin_username = "adminuser"
    admin_password = "P@$$w0rd1234!"
    availability_set_id = azurerm_availability_set.DemoAset.id
    network_interface_ids = [
        azurerm_network_interface.example.id,
    ]

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Debian"
        offer = "debian-11"
        sku = "11"
        version = "latest"
    }
}