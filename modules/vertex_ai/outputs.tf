/**
 * Outputs for the Vertex AI module
 */

output "endpoint_url" {
  description = "The endpoint URL for Vertex AI API access"
  value       = "https://${var.region}-aiplatform.googleapis.com"
}

output "model_ids" {
  description = "Map of model names to their IDs"
  value = {
    for name, model in google_vertex_ai_model.model : name => model.id
  }
}

output "endpoint_ids" {
  description = "Map of model names to their endpoint IDs"
  value = {
    for name, endpoint in google_vertex_ai_endpoint.model_endpoint : name => endpoint.id
  }
}

output "deployment_ids" {
  description = "Map of model names to their deployment IDs"
  value = {
    for name, deployment in google_vertex_ai_model_deployment.model_deployment : name => deployment.id
  }
}

output "private_connection_id" {
  description = "The ID of the private service connection for Vertex AI"
  value       = google_network_connectivity_service_connection_policy.vertex_ai_connection.id
}

output "workbench_instance_id" {
  description = "The ID of the Vertex AI Workbench instance, if created"
  value       = var.create_workbench ? google_notebooks_instance.vertex_ai_workbench[0].id : null
}

output "workbench_instance_url" {
  description = "The URL of the Vertex AI Workbench instance, if created"
  value       = var.create_workbench ? google_notebooks_instance.vertex_ai_workbench[0].proxy_uri : null
}