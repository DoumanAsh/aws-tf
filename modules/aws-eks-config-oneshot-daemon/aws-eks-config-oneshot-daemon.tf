locals {
  label_name       = "${var.name}-version"
  label_version    = md5(var.settings_script)
  settings_prelude = <<-EOT
    set -e
    echo "Applying node settings on $(hostname)..."
  EOT
}

# Our job will put label onto node to ensure we only run it once and able to detect changes when necessary
# So we will create service account that can list and patch existing nodes
resource "kubernetes_service_account_v1" "aws-eks-config-oneshot-daemon" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_v1" "aws-eks-config-oneshot-daemon" {
  metadata {
    name = var.name
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "patch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "aws-eks-config-oneshot-daemon" {
  metadata {
    name = var.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.aws-eks-config-oneshot-daemon.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.aws-eks-config-oneshot-daemon.metadata[0].name
    namespace = kubernetes_service_account_v1.aws-eks-config-oneshot-daemon.metadata[0].namespace
  }
}

# Define daemonset which will be only triggered if our label is not set or missing correct version
resource "kubernetes_daemon_set_v1" "aws-eks-config-oneshot-daemon" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      service = var.name
    }
  }

  spec {
    selector {
      match_labels = {
        service = var.name
      }
    }

    template {
      metadata {
        labels = {
          service = var.name
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.aws-eks-config-oneshot-daemon.metadata[0].name
        priority_class_name  = "system-node-critical"
        host_network         = true
        toleration {
          operator = "Exists"
        }
        affinity {
          node_affinity {
            # All node_selector_term are ORed
            required_during_scheduling_ignored_during_execution {
              # Check if label is missing
              node_selector_term {
                match_expressions {
                  key      = local.label_name
                  operator = "DoesNotExist"
                }
              }

              node_selector_term {
                match_expressions {
                  key      = local.label_name
                  operator = "NotIn"
                  values   = [local.label_version]
                }
              }
            }
          }
        }

        # Run init container with privileges to perform sysctl-init
        init_container {
          name  = "node-config-init"
          image = "public.ecr.aws/docker/library/busybox:stable-musl"
          security_context {
            privileged  = true
            run_as_user = 0
          }

          resources {
            limits = {
              cpu    = "10m"
              memory = "16Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "16Mi"
            }
          }

          command = ["/bin/sh", "-c"]
          args    = [join("\n", [local.settings_prelude, var.settings_script])]
        } # busybox container

        # Apply label with version to identify node that already performed config init
        container {
          image = "registry.k8s.io/kubectl:${var.k8s_version}"
          name  = "node-label-apply"
          security_context {
            privileged                 = false
            run_as_non_root            = true
            run_as_user                = 911
            run_as_group               = 911
            allow_privilege_escalation = false
            read_only_root_filesystem  = false
            capabilities {
              drop = ["all"]
            }
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "16Mi"
            }
          }

          # Acquire node name from spec
          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          # KUBECACHEDIR
          env {
            name  = "KUBECACHEDIR"
            value = "/tmp/.kube/cache"
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }

          command = ["kubectl"]
          args = [
            "label",
            "node",
            "$(NODE_NAME)",
            "${local.label_name}=${local.label_version}",
            "--overwrite"
          ]
        } # kubectl container

        volume {
          name = "tmp"
          empty_dir {
          }
        }
      }
    }
  }

  depends_on = [kubernetes_cluster_role_binding_v1.aws-eks-config-oneshot-daemon]
}
