output "resource_group_name" {
  value = azurerm_resource_group.resource_group.name
}
output "resource_group_location" {
  value = azurerm_resource_group.resource_group.location
  
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.kubernetes_cluster.name
}
output "host" {
  value = azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.host
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.client_certificate
}

output "client_key" {
  value = azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.client_key
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.cluster_ca_certificate
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.username
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.password
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.kubernetes_cluster.kube_config_raw
  sensitive = true
}
output "public_ip_prometheus" {
  value = azurerm_public_ip.prometheus-public-ip.ip_address
}

