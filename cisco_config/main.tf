# Déclaration du fournisseur (provider) Terraform à utiliser
provider "ciscoasa" {
  # Configuration des informations d'authentification pour se connecter au switch Cisco
  host           = "192.168.1.1"
  username       = "admin"
  password       = "password"
}
# Déclaration des ressources Terraform à créer ou modifier sur le switch Cisco
resource "ciscoasa_vlan" "vlan10" {
  vlan_id          = 10
  name             = "VLAN_10"
  description      = "VLAN 10 - Sales Department"
}

resource "ciscoasa_vlan" "vlan20" {
  vlan_id          = 20
  name             = "VLAN_20"
  description      = "VLAN 20 - Marketing Department"
}

resource "ciscoasa_vlan" "vlan30" {
  vlan_id          = 30
  name             = "VLAN_30"
  description      = "VLAN 30 - Management Department"
}
# Exécution de commandes CLI sur le switch Cisco pour assigner les ports aux VLANs
resource "null_resource" "assign_ports" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "admin"
      password    = "password"
      host        = "192.168.1.1"
      port        = 22
      timeout     = "5m"
    }

    # Commandes CLI pour assigner des ports aux VLANs
    inline = [
      "interface GigabitEthernet0/1 ; switchport access vlan 10",
      "interface GigabitEthernet0/2 ; switchport access vlan 10",
      "interface GigabitEthernet0/3 ; switchport access vlan 20",
      "interface GigabitEthernet0/4 ; switchport access vlan 20",
      "interface GigabitEthernet0/5 ; switchport access vlan 30",
      "interface GigabitEthernet0/6 ; switchport access vlan 30"
    ]
  }
}

# Appliquer les modifications sur le switch Cisco en exécutant `terraform apply`
