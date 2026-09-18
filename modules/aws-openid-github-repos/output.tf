output "github_oidc_arn" {
  description = "Github openid connect provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}
