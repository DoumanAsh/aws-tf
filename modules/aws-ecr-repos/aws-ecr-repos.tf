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
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${repo}"
    ]
  }
}

resource "aws_iam_policy" "repository_erc_policy" {
  name        = "aws-ecr-repos-iam-policy"
  description = "Policy to pull/push repositories"
  policy      = data.aws_iam_policy_document.repository_erc_policy.json
}
