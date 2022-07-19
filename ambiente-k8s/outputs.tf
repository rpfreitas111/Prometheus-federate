output "Grupo_de_Recurso" {
  value = module.w2-azurerm.resource_group_name
}
output "Cluster_kubernete" {
  value = module.w2-azurerm.kubernetes_cluster_name
}
output "public_ip_prometheus" {
  value = module.w2-azurerm.public_ip_prometheus
}