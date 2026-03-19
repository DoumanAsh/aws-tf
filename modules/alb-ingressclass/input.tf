variable "name" {
  type        = string
  description = "Name of the Kubernetes IngressClass. Must be a valid k8s resource name."
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "name must match the Kubernetes DNS label"
  }
}

variable "is_default" {
  type        = bool
  description = "Specifies whether this IngressClass shall be used by default when Ingress doesn't have name"
  default     = false
}

variable "scheme" {
  type        = string
  description = "ALB scheme for this class. Valid values: internet-facing, internal."
  validation {
    condition     = contains(["internet-facing", "internal"], var.scheme)
    error_message = "scheme must be one of: internet-facing, internal."
  }
}

variable "ip_address_type" {
  type        = string
  description = "ALB IP address type. Valid values: ipv4, dualstack (requires VPC IPv6)."
  default     = "ipv4"
  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "ip_address_type must be one of: ipv4, dualstack."
  }
}
