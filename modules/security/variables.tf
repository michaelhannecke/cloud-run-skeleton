/**
 * Variables for the security module
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

variable "service_accounts" {
  description = "Map of service accounts to create"
  type = map(object({
    name        = string
    description = string
    roles       = list(string)
    secret_access = optional(list(string), [])
  }))
}

variable "secrets" {
  description = "Map of secrets to create"
  type = map(object({
    name        = string
    description = string
    secret_data = string
  }))
}

variable "kms_key_name" {
  description = "The KMS key name to use for encrypting secrets"
  type        = string
  default     = null
}

variable "create_kms_resources" {
  description = "Whether to create KMS resources"
  type        = bool
  default     = true
}

variable "allowed_policy_member_domains" {
  description = "List of domains allowed in IAM policies"
  type        = list(string)
  default     = []
}

variable "allowed_vpc_peering_projects" {
  description = "List of projects allowed for VPC peering"
  type        = list(string)
  default     = []
}

variable "enable_scc_notifications" {
  description = "Whether to enable Security Command Center notifications"
  type        = bool
  default     = false
}

variable "scc_notification_topic" {
  description = "The Pub/Sub topic for Security Command Center notifications"
  type        = string
  default     = null
}