/**
 * Outputs for the security module
 */

output "service_account_ids" {
  description = "Map of service account names to their IDs"
  value = {
    for name, sa in google_service_account.service_accounts : name => sa.id
  }
}

output "service_account_emails" {
  description = "Map of service account names to their email addresses"
  value = {
    for name, sa in google_service_account.service_accounts : name => sa.email
  }
}

output "secret_ids" {
  description = "Map of secret names to their IDs"
  value = {
    for name, secret in google_secret_manager_secret.secrets : name => secret.id
  }
}

output "kms_key_id" {
  description = "The ID of the KMS key"
  value       = var.create_kms_resources ? google_kms_crypto_key.crypto_key[0].id : null
}

output "kms_keyring_id" {
  description = "The ID of the KMS keyring"
  value       = var.create_kms_resources ? google_kms_key_ring.key_ring[0].id : null
}