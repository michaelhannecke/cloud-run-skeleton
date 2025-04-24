/**
 * Variables for GCP Cloud Run with Vertex AI Integration
 */

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "The deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "vertex_ai_api_key" {
  description = "API key for Vertex AI"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "genai_models" {
  description = "List of GenAI models to use"
  type = list(object({
    name    = string
    version = string
    type    = string
  }))
  default = [
    {
      name    = "text-bison"
      version = "latest"
      type    = "text"
    },
    {
      name    = "gemini-pro"
      version = "latest"
      type    = "multimodal"
    }
  ]
}