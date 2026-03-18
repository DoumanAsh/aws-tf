variable "name" {
  type        = string
  description = "Unique name to be used for creation of resources by this module"
  nullable    = false
}

variable "tags" {
  type        = map(string)
  description = "Optional list of tags to attach to the resources"
  default     = null
}

variable "protocol_version" {
  type        = string
  description = "Application protocol on destination pods. Defaults to HTTP1. Possible values: HTTP1, HTTP2, GRPC"
  default     = "HTTP1"

  validation {
    condition     = contains(["HTTP1", "HTTP2", "GRPC"], var.protocol_version)
    error_message = "Valid values for 'protocol_version' are HTTP1, HTTP2, GRPC."
  }
}

variable "ssl_policy" {
  type        = string
  description = "Specifies security policy to use for TLS handshake. Possible values: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html#tls-security-policies"
  default     = "ELBSecurityPolicy-TLS13-1-1-2021-06"
}

variable "target_type" {
  type        = string
  description = "Describes type of services you're targetting. Use 'ip' for direct network routing to the pod via ClustIP service. Use 'instance' to target NodePort services. Defaults to 'ip'"
  default     = "ip"
}

variable "hostname" {
  type        = string
  description = "Hostname for public endpoint to use"
  nullable    = false
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 zone ID managing the hostname"
  nullable    = false
}

variable "routes" {
  type = list(object({
    service_name = string
    path         = string
    port         = number
  }))
  description = "List of routes to create under this ALB. Wildcard can be placed at the end to match all possible paths with common base"
  nullable    = false
}

variable "health_check_path" {
  type        = string
  description = "Specifies path to health check endpoint for all routes. If not set, defaults to AWS's defaults"
  default     = null
}

variable "health_check_port" {
  type        = number
  description = "Specifies port to use if health_check_path is specified. Defaults to 80"
  default     = 80
}

variable "security_group_id" {
  type        = string
  description = "Security group to attach to the ALB. If not created, AWS shall create security group automatically"
  default     = null
}

variable "idle_timeout_seconds" {
  type        = number
  description = "Ingress Idle timeout value in seconds. Valid value should be in range of 1..=4_000. Defaults to 30s"
  default     = 30
}

variable "keep_alive_time_seconds" {
  type        = number
  description = "Ingress Keep alive time for client. I.e. how long allow connection to persist. Defaults to 7200s(2 hours)"
  default     = 7200
}
