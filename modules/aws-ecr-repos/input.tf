variable "repositories" {
  description = "List of repositories to create"
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "Specify mutability of the tags. Defaults to MUTABLE"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Possible values of image_tag_mutability: 'MUTABLE', 'IMMUTABLE'"
  }
}

variable "scan_on_push" {
  description = "Specifies to perform scan on the image PUSH. Defaults to false"
  type        = bool
  default     = false
}

variable "encryption_type" {
  description = "Specify encryption for repositories. Defaults to AES256"
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Possible values of image_tag_mutability: 'AES256', 'KMS'"
  }
}

variable "tags" {
  type        = map(string)
  description = "Optional list of tags to attach to the resources"
  default     = null
}

variable "continious_scan_type" {
  type        = string
  description = "Specifies type of contitionous scan. Defaults to null"
  default     = null
  validation {
    condition     = var.continious_scan_type == null || contains(["ENHANCED", "BASIC"], var.continious_scan_type)
    error_message = "If continious_scan_type is set, then it should be ENHANCED or BASIC"
  }
}
