data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "repository" {
  for_each             = toset(var.repositories)
  name                 = each.key
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
  }
  tags = var.tags
}

resource "aws_ecr_registry_scanning_configuration" "repository" {
  count     = var.continious_scan_type != null ? 1 : 0
  scan_type = var.continious_scan_type

  rule {
    scan_frequency = "CONTINUOUS_SCAN"
    dynamic "repository_filter" {
      for_each = toset(var.repositories)
      content {
        filter      = repository_filter.value
        filter_type = "WILDCARD"
      }
    }
  }
}

data "aws_iam_policy_document" "repository_erc_policy" {
  # Allow authentication (required for both push & pull)
  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  # Allow pull + push on the specific repositories
  statement {
    sid    = "ECRPushPull"
    effect = "Allow"
    actions = [
      # Pull
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:ListImages",

      # Push
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",

      # Useful extras
      "ecr:GetRepositoryPolicy",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy"
    ]
    resources = [
      for repo in var.repositories :
      "arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/${repo}"
    ]
  }
}

resource "aws_iam_policy" "repository_erc_policy" {
  name        = "aws-ecr-repos-iam-policy"
  description = "Policy to pull/push repositories"
  policy      = data.aws_iam_policy_document.repository_erc_policy.json
}

data "aws_ecr_lifecycle_policy_document" "repository_erc_lifecycle" {
  count = var.lifecycle_untagged_ttl_days != null ? 1 : 0
  rule {
    priority    = 1
    description = "Clean up untagged images"
    selection {
      tag_status   = "untagged"
      count_type   = "sinceImagePushed"
      count_unit   = "days"
      count_number = var.lifecycle_untagged_ttl_days
    }

    action {
      type = "expire"
    }
  }
}

resource "aws_ecr_lifecycle_policy" "repository_erc_lifecycle" {
  for_each   = var.lifecycle_untagged_ttl_days != null ? aws_ecr_repository.repository : {}
  repository = each.value.name
  policy     = data.aws_ecr_lifecycle_policy_document.repository_erc_lifecycle.0.json
}
