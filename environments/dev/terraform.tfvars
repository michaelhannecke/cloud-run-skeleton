# Development environment variables

# Project and region
project_id = "your-project-id-dev"
region     = "us-central1"
environment = "dev"

# Vertex AI configuration
genai_models = [
  {
    name    = "text-bison"
    version = "latest"
    type    = "text"
  }
]

# Security configuration
access_policy_id = "your-access-policy-id"
allowed_policy_member_domains = [
  "yourdomain.com"
]
allowed_vpc_peering_projects = [
  "shared-vpc-project-id"
]

# Optional features
create_workbench = true
enable_model_monitoring = false
enable_scc_notifications = false