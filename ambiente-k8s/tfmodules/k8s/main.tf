resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress" 
  }
}
resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus" 
  }
}
