/**
 * Outputs for the networking module
 */

output "vpc_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = { for subnet in google_compute_subnetwork.subnets : subnet.name => subnet.id }
}

output "vpc_connector_id" {
  description = "The ID of the Serverless VPC Access connector"
  value       = google_vpc_access_connector.connector.id
}

output "vpc_connector_name" {
  description = "The name of the Serverless VPC Access connector"
  value       = google_vpc_access_connector.connector.name
}

output "nat_ip" {
  description = "The NAT IP addresses"
  value       = google_compute_router_nat.nat.nat_ips
}

output "service_perimeter_name" {
  description = "The name of the VPC Service Controls perimeter"
  value       = try(google_access_context_manager_service_perimeter.service_perimeter.name, null)
}