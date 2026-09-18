variable "repositories" {
  description = "List of github repositories to provide access with specified IAM policy via OpenID federation"
  type        = list(string)
}

variable "policy" {
  type        = string
  description = "ARN of the IAM policy to be used by the federation"
}
