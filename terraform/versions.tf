/**
 * Terraform and provider version constraints
 */

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.80.0, < 5.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.80.0, < 5.0.0"
    }
  }
}