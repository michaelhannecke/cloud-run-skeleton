/**
 * Variables for the Cloud Run module
 */

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "project_number" {
  description = "The GCP project number"
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

variable "vpc_connector_id" {
  description = "The ID of the Serverless VPC Access connector"
  type        = string
}

variable "service_account_id" {
  description = "The ID of the service account for Cloud Run services"
  type        = string
}

variable "services" {
  description = "Map of Cloud Run services to deploy"
  type = map(object({
    name          = string
    image         = string
    ingress       = string  # "internal" or "all"
    max_instances = number
    min_instances = number
    cpu           = string
    memory        = string
    concurrency   = optional(number)
    timeout       = optional(number)
    domain        = optional(string)
    env_vars      = optional(map(string))
    secrets       = optional(map(object({
      name    = string
      version = string
    })))
  }))
}