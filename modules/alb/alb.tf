locals {
  security_group_annotation = var.security_group_id != null ? {
    "alb.ingress.kubernetes.io/security-groups" = var.security_group_id,
    # Tell ALB to automatically manage security rules to enable above mentioned SG to pass through EKS's SG
    # Ref: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v3.1/guide/ingress/annotations/#access-control
    "alb.ingress.kubernetes.io/manage-backend-security-group-rules" : "true"
  } : {}
  # We only need it for HTTP, as gRPC will automatically use AWS's builtin target /AWS.ALB/healthcheck
  health_check_annotation = var.health_check_path != null ? {
    "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
    "alb.ingress.kubernetes.io/healthcheck-port"     = format("%d", var.health_check_port)
    "alb.ingress.kubernetes.io/healthcheck-path"     = var.health_check_path
    "alb.ingress.kubernetes.io/success-codes"        = "200"
  } : {}

  lb_annotations = [
    format("idle_timeout.timeout_seconds=%d", var.idle_timeout_seconds),
    format("client_keep_alive.seconds=%d", var.keep_alive_time_seconds)
  ]
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.hostname
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_acme" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id         = var.route53_zone_id
  allow_overwrite = true
  ttl             = 60
  # domain_validation_options may be multiple, but do you need all?
  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_acme : record.fqdn]
}

resource "kubernetes_ingress_v1" "alb" {
  metadata {
    name = var.name
    annotations = merge({
      # We're behind load balancer, so no need for anything more than plain HTTP
      "alb.ingress.kubernetes.io/backend-protocol"         = "HTTP"
      "alb.ingress.kubernetes.io/backend-protocol-version" = var.protocol_version
      "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"              = var.target_type
      "alb.ingress.kubernetes.io/load-balancer-name"       = var.name
      "alb.ingress.kubernetes.io/ssl-policy"               = var.ssl_policy
      # Use HTTPs only
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/certificate-arn" = aws_acm_certificate_validation.cert_validation.certificate_arn
      # https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_LoadBalancerAttribute.html
      "alb.ingress.kubernetes.io/load-balancer-attributes" = join(", ", local.lb_annotations)
    }, local.security_group_annotation, local.health_check_annotation)
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        dynamic "path" {
          for_each = var.routes
          content {
            path = path.value.path
            backend {
              service {
                name = path.value.service_name
                port {
                  number = path.value.port
                }
              }
            }
          }
        }
      }
    }
  }

  wait_for_load_balancer = true
}

data "aws_lb" "this" {
  name = kubernetes_ingress_v1.alb.metadata[0].name
}
