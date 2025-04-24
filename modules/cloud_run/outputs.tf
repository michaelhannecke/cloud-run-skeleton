/**
 * Outputs for the Cloud Run module
 */

output "service_urls" {
  description = "Map of service names to their URLs"
  value = {
    for name, service in google_cloud_run_service.services : name => service.status[0].url
  }
}

output "service_ids" {
  description = "Map of service names to their IDs"
  value = {
    for name, service in google_cloud_run_service.services : name => service.id
  }
}

output "latest_revisions" {
  description = "Map of service names to their latest deployed revisions"
  value = {
    for name, service in google_cloud_run_service.services : name => service.status[0].latest_created_revision_name
  }
}

output "domain_mappings" {
  description = "Map of service names to their domain mappings"
  value = {
    for name, mapping in google_cloud_run_domain_mapping.domain_mapping : name => {
      domain_name = mapping.name
      status      = mapping.status[0].resource_records
    }
    if mapping.status != null
  }
}