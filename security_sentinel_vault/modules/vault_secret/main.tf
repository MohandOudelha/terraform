# Configuration du provider Vault
provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

# Définition des paramètres d'entrée
variable "vault_address" {
  description = "The address of the Vault server."
  type        = string
}

variable "vault_token" {
  description = "The authentication token for accessing the Vault server."
  type        = string
}

# Lecture d'un secret depuis Vault
data "vault_generic_secret" "example_secret" {
  path = "secret/example"

  # Les champs ci-dessous permettent de pointer vers les clés spécifiques dans le secret.
  # Pour ce secret, la clé 'username' contient le nom d'utilisateur et la clé 'password'
  # contient le mot de passe.
  data_json = {
    username = null
    password = null
  }
}

# Affichage des valeurs dans le secret
output "username" {
  value = data.vault_generic_secret.example_secret.data["username"]
}

output "password" {
  value = data.vault_generic_secret.example_secret.data["password"]
}
