/**
 * Main Terraform configuration file for GCP Cloud Run with Vertex AI Integration
 */

locals {
  project_id      = var.project_id
  region          = var.region
  environment     = var.environment
  vpc_name        = "${local.project_id}-vpc-${local.environment}"
  network_tags    = ["cloud-run", "vertex-ai", local.environment]
}

# Create the networking infrastructure
module "networking" {
  source      = "../modules/networking"
  project_id  = local.project_id
  region      = local.region
  environment = local.environment
  vpc_name    = local.vpc_name
  
  # Subnet configurations
  subnets = [
    {
      name          = "cloud-run-subnet"
      ip_cidr_range = "10.0.0.0/20"
      region        = local.region
      purpose       = "PRIVATE"
    },
    {
      name          = "vertex-ai-subnet"
      ip_cidr_range = "10.0.16.0/20"
      region        = local.region
      purpose       = "PRIVATE"
    }
  ]
  
  # Firewall rules
  firewall_rules = {
    allow-internal = {
      name        = "allow-internal"
      description = "Allow internal traffic"
      direction   = "INGRESS"
      ranges      = ["10.0.0.0/16"]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
    }
  }
}

# Set up security configurations
module "security" {
  source      = "../modules/security"
  project_id  = local.project_id
  region      = local.region
  environment = local.environment
  vpc_id      = module.networking.vpc_id
  
  # Service accounts
  service_accounts = {
    cloud_run = {
      name        = "cloud-run-sa"
      description = "Service account for Cloud Run services"
      roles       = [
        "roles/run.invoker",
        "roles/aiplatform.user",
        "roles/secretmanager.secretAccessor"
      ]
    },
    vertex_ai = {
      name        = "vertex-ai-sa"
      description = "Service account for Vertex AI access"
      roles       = [
        "roles/aiplatform.user",
        "roles/aiplatform.serviceAgent"
      ]
    }
  }
  
  # Secrets configuration
  secrets = {
    api_key = {
      name        = "vertex-ai-api-key"
      description = "API key for Vertex AI"
      secret_data = var.vertex_ai_api_key
    },
    db_password = {
      name        = "db-password"
      description = "Database password"
      secret_data = var.db_password
    }
  }
}

# Set up Vertex AI integration
module "vertex_ai" {
  source             = "../modules/vertex_ai"
  project_id         = local.project_id
  region             = local.region
  environment        = local.environment
  vpc_id             = module.networking.vpc_id
  subnet_id          = module.networking.subnet_ids["vertex-ai-subnet"]
  service_account_id = module.security.service_account_ids["vertex_ai"]
  
  # GenAI model configurations
  genai_models = var.genai_models
}

# Deploy Cloud Run services
module "cloud_run" {
  source             = "../modules/cloud_run"
  project_id         = local.project_id
  region             = local.region
  environment        = local.environment
  vpc_id             = module.networking.vpc_id
  vpc_connector_id   = module.networking.vpc_connector_id
  service_account_id = module.security.service_account_ids["cloud_run"]
  
  # Cloud Run service configurations
  services = {
    private_service = {
      name          = "private-service"
      image         = "gcr.io/${local.project_id}/private-service:latest"
      ingress       = "internal"
      max_instances = 10
      min_instances = 0
      cpu           = "1"
      memory        = "512Mi"
      env_vars      = {
        VERTEX_AI_ENDPOINT = module.vertex_ai.endpoint_url
      }
      secrets       = {
        VERTEX_AI_API_KEY = {
          name    = "vertex-ai-api-key"
          version = "latest"
        }
      }
    },
    public_service = {
      name          = "public-service"
      image         = "gcr.io/${local.project_id}/public-service:latest"
      ingress       = "all"
      max_instances = 20
      min_instances = 1
      cpu           = "2"
      memory        = "1Gi"
      env_vars      = {
        VERTEX_AI_ENDPOINT = module.vertex_ai.endpoint_url
      }
      secrets       = {
        VERTEX_AI_API_KEY = {
          name    = "vertex-ai-api-key"
          version = "latest"
        }
      }
    }
  }
}