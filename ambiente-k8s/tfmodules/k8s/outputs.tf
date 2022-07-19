output "namespace_ingress" {
  value = kubernetes_namespace.ingress.id
}
output "namespace_prometheus" {
  value = kubernetes_namespace.prometheus.id
}