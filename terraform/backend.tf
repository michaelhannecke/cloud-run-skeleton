/**
 * Backend configuration for Terraform state
 * This configures Terraform to use the existing GCS bucket for state storage
 */

terraform {
  backend "gcs" {
    # The bucket name will be provided during terraform init via -backend-config
    # Partial configuration is used here
    prefix = "terraform/state"
  }
}