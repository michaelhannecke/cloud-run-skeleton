/**
 * Variables for the Vertex AI module
 */

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC network"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet for Vertex AI resources"
  type        = string
}

variable "service_account_id" {
  description = "The ID of the service account for Vertex AI"
  type        = string
}

variable "kms_key_name" {
  description = "The KMS key name to use for encrypting Vertex AI resources"
  type        = string
  default     = null
}

variable "genai_models" {
  description = "List of GenAI models to deploy"
  type = list(object({
    name    = string
    version = string
    type    = string  # "text" or "multimodal"
  }))
}

variable "create_workbench" {
  description = "Whether to create a Vertex AI Workbench instance"
  type        = bool
  default     = false
}

variable "enable_model_monitoring" {
  description = "Whether to enable model monitoring"
  type        = bool
  default     = false
}