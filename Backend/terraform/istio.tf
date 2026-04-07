resource "kubernetes_namespace_v1" "istio_system" {
  metadata {
    name = "istio-system"
  }
  depends_on = [aws_eks_node_group.workers]
}

# 1. Istio Base CRDs
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace_v1.istio_system.metadata[0].name
  version    = "1.21.0"

  set {
    name  = "defaultRevision"
    value = "default"
  }

  depends_on = [kubernetes_namespace_v1.istio_system]
}

# 2. Istiod (control plane) — YOU WERE MISSING THIS
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace_v1.istio_system.metadata[0].name
  version    = "1.21.0"

  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
  }

  depends_on = [helm_release.istio_base]
}

# 3. Ingress Gateway
resource "helm_release" "istio_ingress" {
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = kubernetes_namespace_v1.istio_system.metadata[0].name
  version    = "1.21.0"

  set {
    name  = "labels.istio"
    value = "ingressgateway"
  }

  depends_on = [helm_release.istiod]
}