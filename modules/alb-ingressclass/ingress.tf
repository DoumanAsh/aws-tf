locals {
  default_class_param_annotations = var.is_default ? {
    "ingressclass.kubernetes.io/is-default-class" : "true"
  } : {}
}

resource "kubernetes_manifest" "ingressclassparams" {
  manifest = {
    apiVersion = "eks.amazonaws.com/v1"
    kind       = "IngressClassParams"
    metadata = {
      name        = var.name
      annotations = local.default_class_param_annotations
    }
    spec = {
      scheme        = var.scheme
      ipAddressType = var.ip_address_type
    }
  }
}

resource "kubernetes_manifest" "ingressclass" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "IngressClass"
    metadata = {
      name = var.name
    }
    spec = {
      controller = "eks.amazonaws.com/alb"
      parameters = {
        apiGroup = "eks.amazonaws.com"
        kind     = "IngressClassParams"
        name     = var.name
      }
    }
  }
  depends_on = [kubernetes_manifest.ingressclassparams]
}
