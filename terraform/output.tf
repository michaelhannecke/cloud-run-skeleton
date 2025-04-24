/**
 * Output definitions for GCP Cloud Run with Vertex AI Integration
 */

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = module.networking.subnet_ids
}

output "vpc_connector_id" {
  description = "The ID of the Serverless VPC Access connector"
  value       = module.networking.vpc_connector_id
}

output "service_account_ids" {
  description = "The IDs of the service accounts"
  value       = module.security.service_account_ids
}

output "cloud_run_urls" {
  description = "The URLs of the Cloud Run services"
  value       = module.cloud_run.service_urls
}

output "vertex_ai_endpoint" {
  description = "The endpoint URL for Vertex AI"
  value       = module.vertex_ai.endpoint_url
}

output "genai_model_ids" {
  description = "The IDs of the GenAI models"
  value       = module.vertex_ai.model_ids
}