# Configuration du provider SSH pour se connecter à la machine Linux cible
provider "ssh" {
  host = "votre_machine_linux_ip"
  username = "votre_nom_utilisateur_ssh"
  password = "votre_mot_de_passe_ssh"
}

# Définition d'une ressource null_resource qui sera utilisée pour exécuter les commandes d'installation de GLPI à distance
resource "null_resource" "install_glpi" {
  # Configuration de la connexion SSH pour la provision à distance
  connection {
    type        = "ssh"
    user        = "votre_nom_utilisateur_ssh"
    password    = "votre_mot_de_passe_ssh"
    host        = "votre_machine_linux_ip"
    timeout     = "2m"
  }

  # Configuration du provisionner remote-exec pour exécuter les commandes d'installation de GLPI à distance
  provisioner "remote-exec" {
    inline = [
      # Mise à jour des packages disponibles dans les sources de paquets
      "sudo apt-get update",
      # Installation des packages nécessaires à l'exécution de GLPI
      "sudo apt-get install apache2 php mysql-server php-mysql wget unzip -y",
      # Téléchargement de l'archive contenant GLPI
      "cd /var/www/html/",
      "sudo wget https://github.com/glpi-project/glpi/releases/download/9.5.5/glpi-9.5.5.tgz",
      # Extraction de l'archive GLPI dans le répertoire /var/www/html/
      "sudo tar -xvzf glpi-9.5.5.tgz",
      # Renommage du répertoire d'installation de GLPI
      "sudo mv glpi/ /var/www/html/",
      # Attribution des droits sur le répertoire d'installation de GLPI pour l'utilisateur Apache
      "sudo chown -R www-data:www-data /var/www/html/glpi/",
      # Définition des permissions sur le répertoire d'installation de GLPI
      "sudo chmod -R 755 /var/www/html/glpi/"
    ]
  }
}
