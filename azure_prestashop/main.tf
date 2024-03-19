terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~>2.0"
        }
    }
}

    # les variables déclarées ici
    variable "admin_username" {
        type = string
        default = "adminuser"
    }

    variable "admin_password" {
        type = string
        default = "P@$$w0rd1234!"
    }


    provider "azurerm" {
    features {}

    subscription_id = "id-compte-azure"
    tenant_id = ""

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

    #  ajouter une ressource "azurerm_network_security_group" avec une règle entrante pour autoriser le trafic sur le port 22.
    resource "azurerm_network_security_group" "nsg" {
        name                = "my-nsg"
        location            = azurerm_resource_group.rg.location
        resource_group_name = azurerm_resource_group.rg.name

        security_rule {
            name                       = "SSH"
            priority                   = 1001
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "22"
            destination_port_range     = "22"
            source_address_prefix      = "10.0.2.0"
            destination_address_prefix = "10.0.2.0"
        }
    }

     resource "azurerm_network_interface_security_group_association" "example" {
            network_interface_id      = azurerm_network_interface.example.id
            network_security_group_id = azurerm_network_security_group.nsg.id
    }

    # Create public IP
            resource "azurerm_public_ip" "public_ip_address" {
                name                         = "public_ip_address"
                location = "france central"
                resource_group_name          = azurerm_resource_group.rg.name
                allocation_method            = "Static"
                sku                          = "Standard"

                tags = {
                    Environment = "Dev"
                }
        }

        # Création d'une machine virtuelle Debian 11
        resource "azurerm_linux_virtual_machine" "debianVM" {
        name                  = "my-vm"
        location              = azurerm_resource_group.rg.location
        resource_group_name   = azurerm_resource_group.rg.name
        size                  = "Standard_B2s"
        admin_username        = "adminuser"
        admin_password = "P@$$w0rd1234!"
        #ssh_password          = "P@$$w0rd1234!"
        disable_password_authentication = false
        network_interface_ids = [
            azurerm_network_interface.example.id,
        ]

        os_disk {
            caching              = "ReadWrite"
            storage_account_type = "Standard_LRS"
            name                 = "my-os-disk"
            #create_option        = "FromImage"
            disk_size_gb         = 30
        }

        source_image_reference {
            publisher = "Debian"
            offer     = "debian-11"
            sku       = "11"
            version   = "latest"
        }
        
            connection {
                type        = "ssh"
                user        = var.admin_username
                password    = var.admin_password
                host        = azurerm_linux_virtual_machine.debianVM.public_ip_address
            }

          provisioner "remote-exec" {
            
            host        = azurerm_linux_virtual_machine.debianVM.public_ip_address

            inline = [
            "sudo apt-get update",
            "sudo apt-get -y install apache2",
            "sudo systemctl start apache2",
            "sudo systemctl enable apache2",
            "sudo apt-get -y install mariadb-server",
            "sudo mysql_secure_installation",
            "sudo apt-get -y install php libapache2-mod-php php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip unzip",
            "cd /var/www/html",
            "sudo rm index.html",
            "sudo wget https://download.prestashop.com/download/releases/prestashop_1.7.7.8.zip",
            "sudo unzip prestashop_1.7.7.8.zip",
            "sudo mv prestashop/* .",
            "sudo chown -R www-data:www-data *",
            "sudo chmod -R 755 *",
            "sudo systemctl restart apache2"
            ]
           
        }
    }
