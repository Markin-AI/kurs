########################### VPC NETWORK  ##############################

resource "yandex_vpc_network" "kurs_net" {
  name = "kurs_net"
}

resource "yandex_vpc_subnet" "kurs-priv-subnet1" {
  name           = "kurs-priv-subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.kurs_net.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  route_table_id = yandex_vpc_route_table.route_table.id
}

resource "yandex_vpc_subnet" "kurs-priv-subnet2" {
  name           = "kurs-priv-subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.kurs_net.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.route_table.id
}

resource "yandex_vpc_subnet" "kurs-pub-subnet" {
  name           = "kurs-pub-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.kurs_net.id
  v4_cidr_blocks = ["192.168.30.0/24"]
  route_table_id = yandex_vpc_route_table.route_table.id
}

###########################  VPC GATEWAY  ##############################

resource "yandex_vpc_gateway" "vpc-natgateway" {
  name = "vpc-natgateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route_table" {
  name       = "route_table"
  network_id = yandex_vpc_network.kurs_net.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.vpc-natgateway.id
  }
}

###########################  SECURITY GROUPS  ###########################

resource "yandex_vpc_security_group" "web-sec-g" {
  name        = "web-sec-g"
  network_id  = "${yandex_vpc_network.kurs_net.id}"

  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    security_group_id = "${yandex_vpc_security_group.bastion-sec-g.id}"
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "prometheus to nginxExp"
    security_group_id = "${yandex_vpc_security_group.prometheusetheus-sec-g.id}"
    port           = 4040
  }

  ingress {
    protocol       = "ANY"
    description    = "prometheus to NodeExp"
    security_group_id = "${yandex_vpc_security_group.prometheusetheus-sec-g.id}"
    port           = 9100
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow HTTP from loadbalancer"
    port           = 80
    v4_cidr_blocks = ["192.168.30.0/24"]
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "bastion-sec-g" {
  name        = "bastion-sec-g"
  network_id  = "${yandex_vpc_network.kurs_net.id}"

  ingress {
    protocol       = "TCP"
    description    = "SSH outside"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "prometheusetheus-sec-g" {
  name        = "prometheusetheus-sec-g"
  network_id  = "${yandex_vpc_network.kurs_net.id}"

  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    security_group_id = "${yandex_vpc_security_group.bastion-sec-g.id}"
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Grafana to prometheus"
    security_group_id = "${yandex_vpc_security_group.grafana-sec-g.id}"
    port           = 9090
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "grafana-sec-g" {
  name        = "grafana-sec-g"
  network_id  = "${yandex_vpc_network.kurs_net.id}"

  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    security_group_id = "${yandex_vpc_security_group.bastion-sec-g.id}"
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "ANY to Grafana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "elastic-sec-g" {
  name        = "elastic-sec-g"
  network_id  = "${yandex_vpc_network.kurs_net.id}"

  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    security_group_id = "${yandex_vpc_security_group.bastion-sec-g.id}"
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Kibana to Elastic"
    security_group_id = "${yandex_vpc_security_group.kibana-sec-g.id}"
    port           = 9200
  }

  ingress {
    protocol       = "TCP"
    description    = "Filebeat to Elastic"
    security_group_id = "${yandex_vpc_security_group.web-sec-g.id}"
    port           = 9200
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "kibana-sec-g" {
  name        = "kibana-sec-g"
  network_id  = "${yandex_vpc_network.kurs_net.id}"

  ingress {
    protocol       = "TCP"
    description    = "SSH from bastion"
    security_group_id = "${yandex_vpc_security_group.bastion-sec-g.id}"
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "ANY to Kibana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

###########################  WEB BALANSER  ##############################

resource "yandex_alb_target_group" "web-tg" {
  name      = "web-tg"

  target {
    subnet_id = "${yandex_vpc_subnet.kurs-priv-subnet1.id}"
    ip_address   = "${yandex_compute_instance.web1.network_interface.0.ip_address}"
  }

  target {
    subnet_id = "${yandex_vpc_subnet.kurs-priv-subnet2.id}"
    ip_address   = "${yandex_compute_instance.web2.network_interface.0.ip_address}"
  }
}

resource "yandex_alb_backend_group" "web-bg" {
  name                     = "web-bg"
/*   session_affinity {
    connection {
      source_ip = true
    }
  } */
  http_backend {
    name                   = "http-back-1"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["${yandex_alb_target_group.web-tg.id}"]
    load_balancing_config {
      panic_threshold      = 90
    }
    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15
      http_healthcheck  {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web-http-router" {
  name          = "web-http-router"
}

resource "yandex_alb_virtual_host" "web-virtual-host" {
  name                    = "web-virtual-host"
  http_router_id          = yandex_alb_http_router.web-http-router.id
  route {
    name                  = "web-route"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.web-bg.id
        timeout           = "60s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web-lb" {
  name        = "web-lb"

  network_id  = yandex_vpc_network.kurs_net.id
  
  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.kurs-pub-subnet.id 
    }
  }
  
  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }    
    http {
      handler {
        http_router_id = yandex_alb_http_router.web-http-router.id
      }
    }
  }
  
  /* log_options {
    discard_rule {
      http_code_intervals = ["2XX"]
      discard_percent = 75
    }
  } */
}

###############################  VMs   ###############################

resource "yandex_compute_instance" "bastion" {
  name = "bastion"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  hostname = "bastion"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8982cg2ridrq7erf1u"
      size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.kurs-pub-subnet.id
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.bastion-sec-g.id}"]
  }
  
  metadata = {
    user-data = "${file("./cloud.yml")}"
  }
}

resource "null_resource" "setup_ansible" {
  provisioner "remote-exec" {
    inline = [
      "mkdir /home/markin/ansible",
      "sudo apt-get update",
      "sudo apt-get install -y ansible"
    ]

    connection {
      type     = "ssh"
      host     = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
      user     = "markin"
      private_key = file("/home/markin/.ssh/id_ed25519")
    }
  }
}

resource "null_resource" "copy_ssh_key" {
  provisioner "file" {
    source      = "/home/markin/.ssh/id_ed25519"
    destination = "/home/markin/.ssh/id_ed25519"

    connection {
      type     = "ssh"
      host     = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
      user     = "markin"
      private_key = file("/home/markin/.ssh/id_ed25519")
    }
  }
  depends_on = [null_resource.setup_ansible]
}

resource "null_resource" "chmod_private_key" {
  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/markin/.ssh/id_ed25519"
    ]

    connection {
      type     = "ssh"
      host     = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
      user     = "markin"
      private_key = file("/home/markin/.ssh/id_ed25519")
    }
  }
  depends_on = [null_resource.copy_ssh_key]
}

resource "yandex_compute_instance" "web1" {
  name = "web1"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  hostname = "web1"

  resources {
    cores  = 2
    core_fraction = 20
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8982cg2ridrq7erf1u"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.kurs-priv-subnet1.id
    nat       = false
    security_group_ids = ["${yandex_vpc_security_group.web-sec-g.id}"] 
  }
  
  metadata = {
    user-data = "${file("./cloud.yml")}"
  }

}

resource "yandex_compute_instance" "web2" {
  name = "web2"
  platform_id = "standard-v1"
  zone = "ru-central1-b"
  hostname = "web2"

  resources {
    cores  = 2
    core_fraction = 20
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8982cg2ridrq7erf1u"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.kurs-priv-subnet2.id
    nat       = false
    security_group_ids = ["${yandex_vpc_security_group.web-sec-g.id}"]
  }
  
  metadata = {
    user-data = "${file("./cloud.yml")}"
  }

}

resource "yandex_compute_instance" "prometheus" {
  name = "prometheus"
  platform_id = "standard-v1"
  zone = "ru-central1-b"
  hostname = "prometheus"

  resources {
    cores  = 2
    core_fraction = 20
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8982cg2ridrq7erf1u"
      size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.kurs-priv-subnet2.id
    nat       = false
    security_group_ids = ["${yandex_vpc_security_group.prometheusetheus-sec-g.id}"]
  }
  
  metadata = {
    user-data = "${file("./cloud.yml")}"
  }

}

resource "yandex_compute_instance" "grafana" {
  name = "grafana"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  hostname = "grafana"

  resources {
    cores  = 2
    core_fraction = 20
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8982cg2ridrq7erf1u"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.kurs-pub-subnet.id
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.grafana-sec-g.id}"]
  }
  
  metadata = {
    user-data = "${file("./cloud.yml")}"
  }

}

resource "yandex_compute_instance" "elastic" {
  name = "elastic"
  platform_id = "standard-v1"
  zone = "ru-central1-b"
  hostname = "elastic"

  resources {
    cores  = 2
    core_fraction = 20
    memory = 6
  }

  boot_disk {
    initialize_params {
      image_id = "fd8982cg2ridrq7erf1u"
      size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.kurs-priv-subnet2.id
    nat       = false
    security_group_ids = ["${yandex_vpc_security_group.elastic-sec-g.id}"]
  }
  
  metadata = {
    user-data = "${file("./cloud.yml")}"
  }

}

resource "yandex_compute_instance" "kibana" {
  name = "kibana"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  hostname = "kibana"

  resources {
    cores  = 2
    core_fraction = 20
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8982cg2ridrq7erf1u"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.kurs-pub-subnet.id
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.kibana-sec-g.id}"]
  }
  
  metadata = {
    user-data = "${file("./cloud.yml")}"
  }

}

###############################  Snapshot   ###############################


resource "yandex_compute_snapshot_schedule" "snapshot_schedule" {
  schedule_policy {
	  expression = "0 0 * * *"
  }

  snapshot_count = 7

  retention_period = "168h"

  disk_ids = ["${yandex_compute_instance.bastion.boot_disk.0.disk_id}","${yandex_compute_instance.web1.boot_disk.0.disk_id}","${yandex_compute_instance.web2.boot_disk.0.disk_id}","${yandex_compute_instance.prometheus.boot_disk.0.disk_id}","${yandex_compute_instance.web2.boot_disk.0.disk_id}","${yandex_compute_instance.grafana.boot_disk.0.disk_id}","${yandex_compute_instance.elastic.boot_disk.0.disk_id}","${yandex_compute_instance.kibana.boot_disk.0.disk_id}"]
}

