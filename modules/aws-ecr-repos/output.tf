output "repositories" {
  description = "Map of ECR repository ARNs, keyed by repository name"
  value       = { for name, value in aws_ecr_repository.repository : name => value.arn }
}

output "repository_urls" {
  description = "Map of repository URLs, keyed by repository name"
  value       = { for name, value in aws_ecr_repository.repository : name => value.repository_url }
}

output "repositroy_iam_policy" {
  description = "Policy ARN for working with the repositories"
  value       = aws_iam_policy.repository_erc_policy.arn
}
