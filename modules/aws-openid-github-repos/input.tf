variable "aws_iam_openid_connect_provider_arn" {
  description = "Already initialized provider's ARN. If not provided, attempts to initialize provider resource. Defaults to null"
  type        = string
  default     = null
}

variable "repositories" {
  description = "List of github repositories to provide access with specified IAM policy via OpenID federation"
  type        = list(string)
}

variable "policy" {
  type        = string
  description = "ARN of the IAM policy to be used by the federation"
}
