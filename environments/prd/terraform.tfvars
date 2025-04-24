# Production environment variables

# Project and region
project_id = "your-project-id-prod"
region     = "us-central1"
environment = "prod"

# Vertex AI configuration
genai_models = [
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

# Security configuration
access_policy_id = "your-access-policy-id"
allowed_policy_member_domains = [
  "yourdomain.com"
]
allowed_vpc_peering_projects = [
  "shared-vpc-project-id"
]

# Optional features
create_workbench = false
enable_model_monitoring = true
enable_scc_notifications = true
scc_notification_topic = "projects/your-project-id-prod/topics/scc-notifications"

# Scaling parameters for Cloud Run services
cloud_run_scaling = {
  private_service = {
    min_instances = 1
    max_instances = 50
  },
  public_service = {
    min_instances = 2
    max_instances = 100
  }
}