/**
 * Vertex AI module for GenAI model integration
 */

# Enable required APIs for Vertex AI
resource "google_project_service" "vertex_ai_api" {
  project = var.project_id
  service = "aiplatform.googleapis.com"
  
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Create a private endpoint for Vertex AI
resource "google_network_connectivity_service_connection_policy" "vertex_ai_connection" {
  name                  = "${var.project_id}-vertex-ai-connection"
  project               = var.project_id
  location              = var.region
  service_class         = "aiplatform.googleapis.com"
  description           = "Vertex AI Private Service Connection"
  network               = var.vpc_id
  psc_connection_id     = "vertex-ai-psc-${var.environment}"
  psc_connection_limit  = 5
  
  depends_on = [google_project_service.vertex_ai_api]
}

# Create a private endpoint for Vertex AI online prediction
resource "google_vertex_ai_endpoint" "model_endpoint" {
  for_each             = { for model in var.genai_models : model.name => model }
  
  name                 = "${each.value.name}-endpoint"
  project              = var.project_id
  region               = var.region
  display_name         = "${each.value.name} Endpoint"
  description          = "Private endpoint for ${each.value.name} model"
  network              = var.vpc_id
  encryption_spec {
    kms_key_name = var.kms_key_name
  }
  
  depends_on = [google_network_connectivity_service_connection_policy.vertex_ai_connection]
}

# Create Vertex AI deployment for each model
resource "google_vertex_ai_model_deployment" "model_deployment" {
  for_each = { for model in var.genai_models : model.name => model }
  
  model            = google_vertex_ai_model.model[each.key].id
  endpoint         = google_vertex_ai_endpoint.model_endpoint[each.key].id
  project          = var.project_id
  region           = var.region
  display_name     = "${each.value.name} Deployment"
  dedicated_resources {
    machine_spec {
      machine_type = "n1-standard-4"
      accelerator_type = "NVIDIA_TESLA_T4"
      accelerator_count = 1
    }
    min_replica_count = 1
    max_replica_count = 2
  }
}

# Create Vertex AI model
resource "google_vertex_ai_model" "model" {
  for_each    = { for model in var.genai_models : model.name => model }
  
  name        = each.value.name
  project     = var.project_id
  region      = var.region
  display_name = "${each.value.name}-${each.value.version}"
  description = "GenAI ${each.value.type} model - ${each.value.name}"
  
  # For public pre-trained models
  parent_model = each.value.type == "text" ? "projects/${var.project_id}/locations/${var.region}/models/text-bison@${each.value.version}" : "projects/${var.project_id}/locations/${var.region}/models/gemini-pro@${each.value.version}"
  
  encryption_spec {
    kms_key_name = var.kms_key_name
  }
}

# Create IAM policy for model access
resource "google_vertex_ai_endpoint_iam_binding" "model_access" {
  for_each = { for model in var.genai_models : model.name => model }
  
  project  = var.project_id
  location = var.region
  endpoint = google_vertex_ai_endpoint.model_endpoint[each.key].name
  role     = "roles/aiplatform.user"
  members  = [
    "serviceAccount:${var.service_account_id}"
  ]
}

# Configure Vertex AI private endpoints
resource "google_compute_address" "private_ip_address" {
  name         = "vertex-ai-private-ip"
  project      = var.project_id
  region       = var.region
  subnetwork   = var.subnet_id
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
}

resource "google_service_networking_connection" "vertex_ai_private_service_connection" {
  network                 = var.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_address.private_ip_address.name]
  
  depends_on = [google_compute_address.private_ip_address]
}

# Create Vertex AI Workbench instance for model testing (optional)
resource "google_notebooks_instance" "vertex_ai_workbench" {
  count        = var.create_workbench ? 1 : 0
  
  name         = "${var.project_id}-workbench"
  project      = var.project_id
  location     = var.region
  machine_type = "n1-standard-4"
  
  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-ent-2-9-cu113"
  }
  
  network = var.vpc_id
  subnet  = var.subnet_id
  
  no_public_ip    = true
  no_proxy_access = false
  
  service_account = var.service_account_id
  
  metadata = {
    proxy-mode       = "project_editors"
    terraform        = "true"
    environment      = var.environment
  }
  
  depends_on = [google_service_networking_connection.vertex_ai_private_service_connection]
}