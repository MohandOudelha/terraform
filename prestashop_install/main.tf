# Définition du fournisseur
provider "ssh" {}

# Définition des variables
variable "prestashop_version" {
  default = "1.7.7.0"
}

# Connexion SSH à l'instance cible
connection {
  type        = "ssh"
  user        = "admin"
  private_key = file("~/.ssh/id_rsa")
  host        = "IP_de_la_machine"
}

# Définition des ressources
resource "null_resource" "install_prestashop" {
  
  # Provisionnement à distance via SSH en utilisant la connexion définie ci-dessus
  provisioner "remote-exec" {
    
    # Commandes à exécuter 
    inline = [
      "apt-get update",
      "apt-get install -y apache2 mariadb-server php php-mysql php-gd php-curl php-intl php-mbstring unzip wget",
      "cd /var/www/html",
      "wget https://download.prestashop.com/download/releases/prestashop_${var.prestashop_version}.zip",
      "unzip prestashop_${var.prestashop_version}.zip",
      "mv prestashop/* ./",
      "rm -rf prestashop/ prestashop_${var.prestashop_version}.zip",
      "chown -R www-data:www-data /var/www/html/",
      "systemctl restart apache2"
    ]
  }
}
