resource "aws_route53_zone" "main" {
  name = "PhongKieuTele.id.vn"
}

data "kubernetes_service_v1" "istio_ingress" {
  metadata {
    name      = "istio-ingress"
    namespace = "istio-system"
  }
  depends_on = [helm_release.istio_ingress]
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.PhongKieuTele.id.vn"
  type    = "CNAME"
  ttl     = 300
  records = [data.kubernetes_service_v1.istio_ingress.status[0].load_balancer[0].ingress[0].hostname]
}

output "route53_name_servers" {
  description = "Add these name servers to your domain registrar for PhongKieuTele.id.vn"
  value       = aws_route53_zone.main.name_servers
}