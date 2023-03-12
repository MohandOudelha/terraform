resource "null_resource" "connexion_ssh" {
  connection {     
    type = "ssh"
    user = "antoine"
    private_key = file("~/.ssh/id_rsa")
    host = "192.168.1.240"
    port = 22
  }

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
}