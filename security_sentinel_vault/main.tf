/*Ce code utilise le plugin Sentinel vault pour interagir avec l'API Vault et vérifier si le mot de passe est stocké 
dans Vault avant la création de la VM Azure. Il utilise également le plugin Terraform azurerm pour créer les ressources 
Azure nécessaires, y compris la VM, l'interface réseau et le sous-réseau.

La politique Sentinel définie dans la section sentinel du fichier Terraform vérifie que la valeur secrète secret/my-app existe 
dans Vault avant la création de la VM Azure. Si la valeur n'existe pas, la règle Sentinel échouera et empêchera la création de 
la VM Azure. Sinon, la règle Sentinel réussira et permettra la création de la VM Azure.
Le code Terraform crée également une ressource vault_generic_secret pour stocker la valeur mysecretpassword dans le stockage 
secret de Vault sous le chemin secret/my-app. La valeur est ensuite récupérée dans la définition de la ressource Azure avec 
vault_generic_secret.my-app.data.password.

Il est important de noter que ce code suppose que vous avez déjà configuré Vault pour être accessible à partir de l'environnement 
Terraform et Sentinel sur Azure. Vous devrez également avoir les bibliothèques Terraform, Sentinel et les plugins hvac et azurerm 
installés et configurés correctement sur votre environnement Terraform.*/

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.0.0"
    }
  }

  required_version = ">= 1.0"

  # Configuration de Sentinel pour valider les règles
  sentinel {
    enabled = true

    policy_set {
      name        = "azure-vm-password"
      description = "Politique pour s'assurer que le mot de passe est stocké dans Vault avant la création d'une VM Azure."

      # Règle Sentinel pour vérifier si le mot de passe est stocké dans Vault
      rules = <<EOF
        import "vault"  # importer le plugin Vault

        # Récupérer la valeur secrète de Vault
        secret_value = vault.read("secret/my-app").data.password

        # Vérifier que la valeur n'est pas nulle
        main = rule {
          secret_value != null
        }
        EOF
    }
  }
}

# ajout du module Vault
module "vault_secrets" {
  source = "./modules/vault_secrets"

  vault_address = var.vault_address
}


# Ressource pour créer une machine virtuelle Azure
resource "azurerm_linux_virtual_machine" "example" {
  name                  = "example-vm"
  location              = "westeurope"
  resource_group_name   = "example-resource-group"
  network_interface_ids = [azurerm_network_interface.example.id]
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  admin_password        = vault_generic_secret.my-app.data.password  # Utiliser la valeur stockée dans Vault
  identity {
    type = "SystemAssigned"
  }
}

# Ressource pour créer une interface réseau pour la VM
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = "westeurope"
  resource_group_name = "example-resource-group"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Ressource pour créer un sous-réseau
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "example-resource-group"
  virtual_network_name = "example-vnet"
  address_prefixes     = ["10.0.2.0/24"]
}
