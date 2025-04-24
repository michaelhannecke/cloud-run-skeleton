/**
 * Security module for IAM, Secret Manager, and security controls
 */

# Create service accounts
resource "google_service_account" "service_accounts" {
  for_each     = var.service_accounts
  
  account_id   = each.value.name
  project      = var.project_id
  display_name = each.value.description
  description  = "Service account for ${each.value.name} in ${var.environment} environment"
}

# Assign IAM roles to service accounts
resource "google_project_iam_member" "service_account_roles" {
  for_each = {
    for binding in flatten([
      for sa_key, sa in var.service_accounts : [
        for role in sa.roles : {
          sa_key = sa_key
          role   = role
        }
      ]
    ]) : "${binding.sa_key}-${binding.role}" => binding
  }
  
  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.service_accounts[each.value.sa_key].email}"
}

# Create secrets in Secret Manager
resource "google_secret_manager_secret" "secrets" {
  for_each  = var.secrets
  
  project   = var.project_id
  secret_id = each.value.name
  
  replication {
    auto {
      customer_managed_encryption {
        kms_key_name = var.kms_key_name
      }
    }
  }
  
  labels = {
    environment = var.environment
  }
}

# Store secret values
resource "google_secret_manager_secret_version" "secret_versions" {
  for_each = var.secrets
  
  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value.secret_data
}

# Grant access to secrets
resource "google_secret_manager_secret_iam_member" "secret_access" {
  for_each = {
    for binding in flatten([
      for secret_key, secret in var.secrets : [
        for sa_key, sa in var.service_accounts : {
          secret_key = secret_key
          sa_key     = sa_key
        }
        if contains(sa.secret_access, secret_key)
      ]
    ]) : "${binding.secret_key}-${binding.sa_key}" => binding
  }
  
  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.value.secret_key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service_accounts[each.value.sa_key].email}"
}

# Create a customer-managed encryption key (CMEK)
resource "google_kms_key_ring" "key_ring" {
  count    = var.create_kms_resources ? 1 : 0
  
  name     = "${var.project_id}-${var.environment}-keyring"
  project  = var.project_id
  location = var.region
}

resource "google_kms_crypto_key" "crypto_key" {
  count           = var.create_kms_resources ? 1 : 0
  
  name            = "${var.project_id}-${var.environment}-key"
  key_ring        = google_kms_key_ring.key_ring[0].id
  rotation_period = "7776000s"  # 90 days
  
  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
}

# Set up Organization Policy constraints for enhanced security
resource "google_project_organization_policy" "domain_restricted_sharing" {
  project    = var.project_id
  constraint = "iam.allowedPolicyMemberDomains"

  list_policy {
    allow {
      values = var.allowed_policy_member_domains
    }
  }
}

resource "google_project_organization_policy" "require_oslogin" {
  project    = var.project_id
  constraint = "compute.requireOsLogin"

  boolean_policy {
    enforced = true
  }
}

resource "google_project_organization_policy" "disable_service_account_key_creation" {
  project    = var.project_id
  constraint = "iam.disableServiceAccountKeyCreation"

  boolean_policy {
    enforced = true
  }
}

resource "google_project_organization_policy" "restrict_vpc_peering" {
  project    = var.project_id
  constraint = "compute.restrictVpcPeering"

  list_policy {
    allow {
      values = var.allowed_vpc_peering_projects
    }
  }
}

# Security Command Center notification config
resource "google_scc_notification_config" "scc_notifications" {
  count         = var.enable_scc_notifications ? 1 : 0
  
  config_id     = "${var.project_id}-scc-notifications"
  project       = var.project_id
  description   = "Security Command Center notifications for ${var.environment} environment"
  pubsub_topic  = var.scc_notification_topic
  
  streaming_config {
    filter = "state = \"ACTIVE\""
  }
}