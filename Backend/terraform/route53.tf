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

locals {
  elb_hostname = data.kubernetes_service_v1.istio_ingress.status[0].load_balancer[0].ingress[0].hostname
  # AWS Network Load Balancer (NLB) hosted zone IDs per region (static, published by AWS)
  elb_zone_ids = {
    "us-east-1"      = "Z26RNL4JYFTOTI"
    "us-east-2"      = "ZLMOA37VPKANP"
    "us-west-1"      = "Z24FKFUX50B4VW"
    "us-west-2"      = "Z18D5FSROUN65G"
    "ap-southeast-1" = "ZKVM4W9LS7TM"
    "eu-west-1"      = "Z2IFOLAFXWLO4F"
  }
  elb_zone_id = local.elb_zone_ids[var.aws_region]
}

# Root domain — must use ALIAS (not CNAME) at zone apex
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "PhongKieuTele.id.vn"
  type    = "A"

  alias {
    name                   = local.elb_hostname
    zone_id                = local.elb_zone_id
    evaluate_target_health = true
  }
}

# www
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.PhongKieuTele.id.vn"
  type    = "CNAME"
  ttl     = 300
  records = [local.elb_hostname]
}

# API
resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.PhongKieuTele.id.vn"
  type    = "CNAME"
  ttl     = 300
  records = [local.elb_hostname]
}

# Grafana
resource "aws_route53_record" "grafana" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "grafana.PhongKieuTele.id.vn"
  type    = "CNAME"
  ttl     = 300
  records = [local.elb_hostname]
}

# Prometheus
resource "aws_route53_record" "prometheus" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "prometheus.PhongKieuTele.id.vn"
  type    = "CNAME"
  ttl     = 300
  records = [local.elb_hostname]
}

# Splunk
resource "aws_route53_record" "splunk" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "splunk.PhongKieuTele.id.vn"
  type    = "CNAME"
  ttl     = 300
  records = [local.elb_hostname]
}

output "route53_name_servers" {
  description = "Add these name servers to your domain registrar for PhongKieuTele.id.vn"
  value       = aws_route53_zone.main.name_servers
}
