# Définit les variables nécessaires
variable "ssh_username" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}

variable "ip_address" {
  type = string
}

# Crée une ressource Null qui représente notre tâche de mise à jour
resource "null_resource" "update_debian" {

  # Utilise le provisionner "remote-exec" pour exécuter des commandes via SSH
  provisioner "remote-exec" {

    # Les commandes que nous allons exécuter pour mettre à jour Debian
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y"
    ]

    # Configure la connexion SSH pour se connecter à l'instance
    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file(var.ssh_private_key_path)
      host        = var.ip_address
    }
  }
}
