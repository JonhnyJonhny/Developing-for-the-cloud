resource "kubernetes_namespace_v1" "istio_system" {
  metadata {
    name = "istio-system"
  }
  depends_on = [aws_eks_node_group.workers]

  timeouts {
    delete = "10m"
  }

  # Runs AFTER all helm releases are destroyed (they depend on this namespace)
  # but BEFORE the namespace delete API call is sent
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "Cleaning up istio-system namespace resources..."
      kubectl delete all --all -n istio-system --force --grace-period=0 2>/dev/null || true
      kubectl delete configmaps --all -n istio-system 2>/dev/null || true
      kubectl delete secrets --all -n istio-system --field-selector type!=kubernetes.io/service-account-token 2>/dev/null || true
      kubectl get namespace istio-system -o json 2>/dev/null \
        | python3 -c "import sys,json; ns=json.load(sys.stdin); ns['spec']['finalizers']=[]; print(json.dumps(ns))" 2>/dev/null \
        | kubectl replace --raw /api/v1/namespaces/istio-system/finalize -f - 2>/dev/null || true
      echo "Cleanup complete."
    EOT
    on_failure = continue
  }
}

# 1. Istio Base CRDs
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace_v1.istio_system.metadata[0].name
  version    = "1.21.0"
  wait       = true
  atomic     = true
  timeout    = 300

  set {
    name  = "defaultRevision"
    value = "default"
  }

  depends_on = [kubernetes_namespace_v1.istio_system]
}

# 2. Istiod (control plane)
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace_v1.istio_system.metadata[0].name
  version    = "1.21.0"
  wait       = true
  atomic     = true
  timeout    = 300

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
  wait       = true
  atomic     = true
  timeout    = 300

  set {
    name  = "labels.istio"
    value = "ingressgateway"
  }

  depends_on = [helm_release.istiod]
}