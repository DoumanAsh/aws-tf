terraform {
  required_providers {
    aws = {
      source  = "aws"
      version = "~> 6"
    }
    kubernetes = {
      source  = "kubernetes"
      version = ">=2, <4"
    }

  }
}
