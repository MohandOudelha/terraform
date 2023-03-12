provider "ssh" {
  host = "192.168.1.1"
  user = "admin"
  password = "password123"
}

resource "ssh_command" "config_network" {
  command = <<EOT
    conf t
    interface GigabitEthernet1/0/1
    description Server Connection
    switchport mode access
    switchport access vlan 10
    no shutdown
    exit
    interface GigabitEthernet1/0/2
    description Router Connection
    switchport mode trunk
    switchport trunk allowed vlan 10,20,30
    no shutdown
    exit
    vlan 10
    name Server
    exit
    vlan 20
    name Marketing
    exit
    vlan 30
    name Engineering
    exit
    end
    wr
  EOT
}
