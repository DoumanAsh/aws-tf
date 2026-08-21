variable "name" {
  description = "Name of the daemonset used"
  type        = string
  default     = "eks-sys-config-oneshot"
}

variable "namespace" {
  description = "EKS Namespace to create daemon set in"
  type        = string
  default     = "kube-system"
}

# We can use aws_eks_cluster.version to fetch exact server version, if we want to be 100% safe
# https://registry.terraform.io/providers/-/aws/latest/docs/data-sources/eks_cluster#version-2
# Use https://explore.ggcr.dev/ to explore available tags of registry.k8s.io/kubectl
variable "k8s_version" {
  description = "Kubernetes version to target. This is used to select version of registry.k8s.io/kubectl container that executes actions"
  type        = string
  default     = "v1.34.9"
}

variable "settings_script" {
  description = "Settings to apply on the node using public.ecr.aws/docker/library/busybox. Defaults to adjusting swappiness to reasonable value"
  type        = string
  default     = <<-EOT
    sysctl -w vm.swappiness=60
  EOT
}
