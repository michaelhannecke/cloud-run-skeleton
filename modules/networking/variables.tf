/**
 * Variables for the networking module
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

variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    purpose       = string
  }))
}

variable "firewall_rules" {
  description = "Map of firewall rules to create"
  type = map(object({
    name        = string
    description = string
    direction   = string
    ranges      = list(string)
    allow = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))
}

variable "access_policy_id" {
  description = "The ID of the access policy for VPC Service Controls"
  type        = string
  default     = null
}