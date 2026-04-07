resource "kubernetes_namespace_v1" "istio_system" {
  metadata {
    name = "istio-system"
  }
  depends_on = [ aws_eks_node_group.workers ]
}

resource "helm_release" "istio" {
  name = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "base"
  namespace = kubernetes_namespace_v1.istio_system.metadata[0].name

  set {
    name = "global.defaultPodLabels.istio-injection"
    value = "enabled"
  }

  depends_on = [ kubernetes_namespace_v1.istio_system ]
}

resource "helm_release" "istio_ingress" {
  name = "istio-gateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "gateway"
  namespace = kubernetes_namespace_v1.istio_system.metadata[0].name

  set {
    name = "hub"
    value = "docker.io/istio"
  }

  set{
    name "tag"
    value = "1.21.0"
  }

  depends_on = [ helm_release.istio ]
}
