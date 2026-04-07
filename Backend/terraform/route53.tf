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

data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "app_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "PhongKieuTele.id.vn"
  type    = "A"

  alias {
    name                   = data.kubernetes_service_v1.istio_ingress.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

output "route53_output" {
  description = "copy to dns service"
  value = aws_route53_zone.main.name_servers
}