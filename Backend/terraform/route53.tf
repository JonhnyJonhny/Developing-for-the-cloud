resource "aws_route53_zone" "main" {
  name = "PhongKieuTele.id.vn"
}

data "kubernetes_service_v1" "istio_ingress" {
  metadata {
    name = "istio-ingressgateway"
    namespace = kubernetes_namespace_v1.istio_system.metadata[0].name
  }
  depends_on = [ helm_release.istio_ingress ]
}

data "aws_lb" "istio_ingress" {
  tags = {
    "kubernetes.io/cluster/budget-app-cluster" = "owned"
    "kubernetes.io/service-name"               = "istio-system/istio-ingressgateway"
  }
  depends_on = [helm_release.istio_ingress]
}

resource "aws_route53_record" "app_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "PhongKieuTele.id.vn"
  type    = "A"

  alias {
    name                   = data.aws_lb.istio_ingress.dns_name
    zone_id                = data.aws_lb.istio_ingress.zone_id
    evaluate_target_health = true
  }
}

output "route53_output" {
  description = "copy to dns service"
  value = aws_route53_zone.main.name_servers
}