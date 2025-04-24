/**
 * IAM configuration for GCP Cloud Run with Vertex AI Integration
 * Implements least privilege principle for all service accounts
 */

# Custom IAM roles for least privilege
resource "google_project_iam_custom_role" "cloud_run_runtime" {
  role_id     = "cloudRunRuntime"
  title       = "Cloud Run Runtime Role"
  description = "Minimal permissions for Cloud Run services to access Vertex AI and secrets"
  permissions = [
    "run.services.get",
    "run.services.invoke",
    "aiplatform.endpoints.predict",
    "aiplatform.models.predict",
    "secretmanager.versions.access",
    "logging.logEntries.create"
  ]
}

resource "google_project_iam_custom_role" "vertex_ai_runtime" {
  role_id     = "vertexAiRuntime"
  title       = "Vertex AI Runtime Role"
  description = "Minimal permissions for Vertex AI service account"
  permissions = [
    "aiplatform.endpoints.predict",
    "aiplatform.models.predict",
    "aiplatform.models.get",
    "aiplatform.operations.get",
    "logging.logEntries.create"
  ]
}

# Deployment service account
resource "google_service_account" "terraform_deployer" {
  account_id   = "terraform-deployer"
  display_name = "Terraform Deployment Service Account"
  description  = "Service account for deploying Terraform resources"
}

# Assign minimal permissions to the deployment service account
resource "google_project_iam_member" "terraform_deployer_permissions" {
  for_each = toset([
    "roles/compute.networkAdmin",
    "roles/run.admin",
    "roles/aiplatform.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/secretmanager.admin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/servicenetworking.serviceAgent",
    "roles/vpcaccess.admin",
    "roles/cloudkms.admin"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform_deployer.email}"
}

# Service account for Cloud Run services
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-sa"
  display_name = "Cloud Run Service Account"
  description  = "Service account for Cloud Run services with minimal permissions"
}

# Apply custom role to Cloud Run service account
resource "google_project_iam_member" "cloud_run_sa_custom_role" {
  project = var.project_id
  role    = google_project_iam_custom_role.cloud_run_runtime.id
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Additional required predefined roles for Cloud Run SA
resource "google_project_iam_member" "cloud_run_sa_additional_roles" {
  for_each = toset([
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Service account for Vertex AI
resource "google_service_account" "vertex_ai_sa" {
  account_id   = "vertex-ai-sa"
  display_name = "Vertex AI Service Account"
  description  = "Service account for Vertex AI with minimal permissions"
}

# Apply custom role to Vertex AI service account
resource "google_project_iam_member" "vertex_ai_sa_custom_role" {
  project = var.project_id
  role    = google_project_iam_custom_role.vertex_ai_runtime.id
  member  = "serviceAccount:${google_service_account.vertex_ai_sa.email}"
}

# Additional required predefined roles for Vertex AI SA
resource "google_project_iam_member" "vertex_ai_sa_additional_roles" {
  for_each = toset([
    "roles/aiplatform.serviceAgent",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vertex_ai_sa.email}"
}

# Allow Cloud Run SA to invoke specific Cloud Run services
resource "google_cloud_run_service_iam_member" "cloud_run_sa_invoker" {
  for_each = var.private_cloud_run_services
  
  location = var.region
  project  = var.project_id
  service  = each.value
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Grant Vertex AI SA access to specific models
resource "google_vertex_ai_endpoint_iam_binding" "vertex_ai_sa_model_access" {
  for_each = var.vertex_ai_endpoints
  
  project  = var.project_id
  location = var.region
  endpoint = each.value
  role     = "roles/aiplatform.user"
  members  = [
    "serviceAccount:${google_service_account.vertex_ai_sa.email}",
    "serviceAccount:${google_service_account.cloud_run_sa.email}"
  ]
}

# Allow specific service identities to access secrets
resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  for_each = {
    for mapping in flatten([
      for secret_id, service_accounts in var.secret_access_mapping : [
        for sa in service_accounts : {
          secret_id = secret_id
          sa        = sa
        }
      ]
    ]) : "${mapping.secret_id}-${mapping.sa}" => mapping
  }
  
  project   = var.project_id
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value.sa}"
}

# Workload identity for GitHub Actions (optional)
resource "google_service_account" "github_actions" {
  count        = var.enable_github_actions ? 1 : 0
  
  account_id   = "github-actions"
  display_name = "GitHub Actions Service Account"
  description  = "Service account for GitHub Actions CI/CD with least privilege"
}

resource "google_project_iam_member" "github_actions_roles" {
  for_each = var.enable_github_actions ? toset([
    "roles/storage.objectViewer",
    "roles/artifactregistry.reader"
  ]) : []
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions[0].email}"
}

# Variables for IAM access control
variable "private_cloud_run_services" {
  description = "Map of private Cloud Run service names to grant access to"
  type        = map(string)
  default     = {}
}

variable "vertex_ai_endpoints" {
  description = "Map of Vertex AI endpoint names to grant access to"
  type        = map(string)
  default     = {}
}

variable "secret_access_mapping" {
  description = "Map of secret IDs to list of service account emails that should access them"
  type        = map(list(string))
  default     = {}
}

variable "enable_github_actions" {
  description = "Whether to create a service account for GitHub Actions"
  type        = bool
  default     = false
}

# Outputs
output "cloud_run_service_account" {
  description = "The email of the Cloud Run service account"
  value       = google_service_account.cloud_run_sa.email
}

output "vertex_ai_service_account" {
  description = "The email of the Vertex AI service account"
  value       = google_service_account.vertex_ai_sa.email
}

output "terraform_deployer_service_account" {
  description = "The email of the Terraform deployment service account"
  value       = google_service_account.terraform_deployer.email
}

output "github_actions_service_account" {
  description = "The email of the GitHub Actions service account"
  value       = var.enable_github_actions ? google_service_account.github_actions[0].email : null
}