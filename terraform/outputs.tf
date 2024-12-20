output "external_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}
output "external_ip_address_load_balancer" {
  value = yandex_alb_load_balancer.web-lb.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
} 
output "external_ip_address_grafana" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}
output "external_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}
output "internal_ip_address_WEB1" {
  value = yandex_compute_instance.web1.network_interface.0.ip_address
}
output "internal_ip_address_WEB2" {
  value = yandex_compute_instance.web2.network_interface.0.ip_address
}
output "internal_ip_address_elastic" {
  value = yandex_compute_instance.elastic.network_interface.0.ip_address
}
output "internal_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
}
output "internal_ip_address_prometheus" {
  value = yandex_compute_instance.prometheus.network_interface.0.ip_address
}
output "internal_ip_address_grafana" {
  value = yandex_compute_instance.grafana.network_interface.0.ip_address
}
