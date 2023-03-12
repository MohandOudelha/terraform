provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.example.name
}

resource "azurerm_public_ip" "example" {
  name                = "example-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "example-ip-config"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  size                = "Standard_DS2_v2"
  admin_username      = "adminuser"
  disable_password_authentication = true

  admin_ssh_key {
    username = "adminuser"
    public_key = "ssh-rsa ABCDE"
  }

  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11"
    version   = "latest"
  }

  os_disk {
    name              = "example-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Provision a script to install Prestashop
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/adminuser/.ssh/authorized_keys"
      key_data = "ssh-rsa ABCDE"
    }
  }


    # ouverture dur port 80 avec le module "azurerm_network_security_group"
    resource "azurerm_network_security_group" "example" {
        name                = "example-nsg"
        location            = azurerm_resource_group.example.location
        resource_group_name = azurerm_resource_group.example.name

            security_rule {
                name                       = "allow-http"
                priority                   = 100
                direction                  = "Inbound"
                access                     = "Allow"
                protocol                   = "Tcp"
                source_port_range          = "*"
                destination_port_range     = "80"
                source_address_prefix      = "*"
                destination_address_prefix = "*"
            }
    }
  
  # le remote-exec pour mettre à jour le système et installer prestashop et les composants nécessaires
  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt upgrade",
      "sudo apt install apache2 -y",
      "sudo apt install mariadb-server mariadb-client -y",
      "sudo apt install php7.4 libapache2-mod-php7.4 php7.4-common php7.4-mysql php7.4-gd php7.4-json php7.4-curl php7.4-zip php7.4-xml php7.4-mbstring php7.4-bcmath php7.4-soap -y",
      "sudo systemctl restart apache2.service",
      "sudo mysql -e 'CREATE DATABASE glpidb;'",
      "sudo mysql -e 'GRANT ALL PRIVILEGES ON glpidb.* TO \"glpiuser\"@\"localhost\" IDENTIFIED BY \"glpipass\";'",
      "sudo mysql -e 'FLUSH PRIVILEGES;'",
      "cd /var/www/html",
      "sudo wget https://github.com/glpi-project/glpi/releases/download/9.5.7/glpi-9.5.7.tgz",
      "sudo tar xzf glpi-9.5.7.tgz",
      "sudo chown -R www-data:www-data /var/www/html/glpi/",
      "sudo chmod -R 755 /var/www/html/glpi/",
      "sudo systemctl restart apache2.service"
    ]
  }