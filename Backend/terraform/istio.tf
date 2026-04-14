resource "helm_release" "istio_base" {
  name = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "base"
  namespace = "istio-system"
  create_namespace = true
  depends_on = [ aws_eks_node_group.app_nodes ]
}

resource "helm_release" "istiod" {
  name = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "istiod"
  namespace = "istio-system"
  depends_on = [ helm_release.istio_base ]
}

resource "helm_release" "istio_ingress" {
  name = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "gateway"
  namespace = "istio-system"
  depends_on = [ helm_release.istiod ]
  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
}

# Enable Istio sidecar injection in the default namespace
resource "kubernetes_labels" "default_ns_istio" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "default"
  }
  labels = {
    "istio-injection" = "enabled"
  }
  depends_on = [helm_release.istiod]
}