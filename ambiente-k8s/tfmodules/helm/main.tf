resource "helm_release" "ingress-nginx-controller" {
  name       = "ingress-nginx-controller"
  namespace  = "ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.1.1"
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  set{
    name="controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value="true"
  }
    depends_on = [ 
    var.ingress
  ]
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version = "15.10.1"
  namespace = "prometheus"
  depends_on = [
    helm_release.ingress-nginx-controller,
    var.prometheus,
  ]
  values = [
    <<-EOT
        kubeStateMetrics:
            enabled: false
        alertmanager:
            enabled: false
        server:
            retention: "2d"
            ingress:
                enabled: true
                annotations:
                    kubernetes.io/ingress.class: nginx
                    nginx.ingress.kubernetes.io/enable-cors: "true"
                    nginx.ingress.kubernetes.io/cors-allow-origin: "*"
                    # nginx.ingress.kubernetes.io/whitelist-source-range: "192.168.0.1/32" 
                extraLabels: {}
                hosts: ["prometheus-dev.test.com.br"]
                path: /
                pathType: Prefix
                extraPaths: []
    EOT
  ]
}

resource "helm_release" "kube-state-metrics" {
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version = "4.9.2"
  namespace = "prometheus"
  depends_on = [
    helm_release.prometheus,
    var.prometheus,
  ]
}
