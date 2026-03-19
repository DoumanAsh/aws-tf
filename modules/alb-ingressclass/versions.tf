terraform {
  required_providers {
    kubernetes = {
      source  = "kubernetes"
      version = ">=2, <4"
    }

  }
}
