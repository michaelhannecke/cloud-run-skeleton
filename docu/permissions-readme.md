# Required Permissions and APIs

This document outlines the required permissions and APIs for deploying and running the secure Cloud Run with Vertex AI integration infrastructure.

## Required APIs

Before deploying the infrastructure, ensure the following APIs are enabled in your GCP project:

### Core APIs
- `compute.googleapis.com` - Compute Engine API
- `servicenetworking.googleapis.com` - Service Networking API
- `run.googleapis.com` - Cloud Run API
- `aiplatform.googleapis.com` - Vertex AI API
- `secretmanager.googleapis.com` - Secret Manager API
- `iam.googleapis.com` - Identity and Access Management API

### Additional APIs
- `cloudkms.googleapis.com` - Cloud Key Management Service API
- `vpcaccess.googleapis.com` - Serverless VPC Access API
- `notebooks.googleapis.com` - Notebooks API
- `accesscontextmanager.googleapis.com` - Access Context Manager API
- `securitycenter.googleapis.com` - Security Command Center API
- `dns.googleapis.com` - Cloud DNS API
- `networkconnectivity.googleapis.com` - Network Connectivity API

## Enabling APIs

We provide scripts to enable all required APIs:

### For Linux/Mac:
```bash
# Make script executable
chmod +x scripts/enable-apis.sh

# Run script with your project ID
./scripts/enable-apis.sh your-project-id
```

### For Windows:
```cmd
# Run script with your project ID
scripts\enable-apis.bat your-project-id
```

## IAM Configuration

The project follows the principle of least privilege with custom roles and service accounts:

### Service Accounts

1. **Terraform Deployer Service Account**:
   - Used only for infrastructure deployment
   - Has administrative permissions for resource creation

2. **Cloud Run Service Account**:
   - Used by Cloud Run services at runtime
   - Has minimal permissions to access only required resources

3. **Vertex AI Service Account**:
   - Used by Vertex AI services
   - Has permissions only for AI model operations

### Custom Roles

Custom IAM roles are created to provide precise permission sets:

1. **Cloud Run Runtime Role**:
   - Minimal permissions for Cloud Run services
   - Includes only permissions needed to access Vertex AI and secrets

2. **Vertex AI Runtime Role**:
   - Minimal permissions for AI operations
   - Limited to prediction and logging capabilities

## Pre-Deployment Setup

Before deploying the infrastructure, you must:

1. Ensure the deploying user or service account has `roles/owner` or equivalent permissions
2. Enable all required APIs (using the provided scripts)
3. Create a GCS bucket for Terraform state
4. Ensure organization policies allow the creation of required resources

## Post-Deployment

After deployment, review the IAM permissions and consider:

1. Removing the Terraform deployer service account's permissions
2. Setting up audit logging for all IAM changes
3. Implementing regular permission reviews

For detailed information about the specific permissions and roles, see [IAM-PERMISSIONS.md](./IAM-PERMISSIONS.md).
