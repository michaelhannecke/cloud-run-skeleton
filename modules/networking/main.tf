/**
 * Networking module for GCP Cloud Run with Vertex AI Integration
 */

# Create VPC network
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "VPC network for ${var.environment} environment"
}

# Create subnets
resource "google_compute_subnetwork" "subnets" {
  for_each      = { for subnet in var.subnets : subnet.name => subnet }
  
  name          = each.value.name
  project       = var.project_id
  region        = each.value.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = each.value.ip_cidr_range
  purpose       = each.value.purpose
  
  # Enable Private Google Access
  private_ip_google_access = true
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Create firewall rules
resource "google_compute_firewall" "rules" {
  for_each    = var.firewall_rules
  
  name        = each.value.name
  project     = var.project_id
  network     = google_compute_network.vpc.id
  description = each.value.description
  direction   = each.value.direction
  
  source_ranges = lookup(each.value, "ranges", null)
  
  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }
  
  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", null)
    }
  }
}

# Create NAT for outbound connectivity
resource "google_compute_router" "router" {
  name    = "${var.vpc_name}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Create Serverless VPC Access connector for Cloud Run
resource "google_vpc_access_connector" "connector" {
  name          = "${var.vpc_name}-connector"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.8.0.0/28"  # Dedicated /28 range for the connector
  
  # Standard machine type is recommended for production
  machine_type = "e2-standard-4"
  min_instances = 2
  max_instances = 10
}

# Set up Private Service Connect for Vertex AI
resource "google_compute_global_address" "private_service_connect" {
  name          = "${var.vpc_name}-psc"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_service_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_connect.name]
}

# Set up VPC Service Controls (requires google-beta provider)
resource "google_access_context_manager_service_perimeter" "service_perimeter" {
  provider       = google-beta
  parent         = "accessPolicies/${var.access_policy_id}"
  name           = "accessPolicies/${var.access_policy_id}/servicePerimeters/${var.project_id}-perimeter"
  title          = "${var.project_id} Service Perimeter"
  perimeter_type = "PERIMETER_TYPE_REGULAR"
  
  status {
    resources = ["projects/${var.project_id}"]
    
    restricted_services = [
      "run.googleapis.com",
      "aiplatform.googleapis.com",
      "secretmanager.googleapis.com"
    ]
    
    vpc_accessible_services {
      enable_restriction = true
      allowed_services   = ["RESTRICTED-SERVICES"]
    }
    
    ingress_policies {
      ingress_from {
        sources {
          resource = "projects/${var.project_id}"
        }
        identity_type = "ANY_IDENTITY"
        identities    = []
      }
      ingress_to {
        resources = ["*"]
        operations {
          service_name = "run.googleapis.com"
          method_selectors {
            method = "*"
          }
        }
      }
    }
    
    egress_policies {
      egress_from {
        identities = []
        identity_type = "ANY_IDENTITY"
      }
      egress_to {
        resources = ["projects/${var.project_id}"]
        operations {
          service_name = "*"
          method_selectors {
            method = "*"
          }
        }
      }
    }
  }
}