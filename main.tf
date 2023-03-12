

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

      "sudo apt update && sudo apt upgrade > /home/antoine/Documents/test.txt"

  
    ]
  }
}