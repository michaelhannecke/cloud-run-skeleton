# IAM Permissions and Least Privilege Access

This document explains the IAM roles and permissions used in this project, adhering to the principle of least privilege.

## Overview

The infrastructure uses custom IAM roles and service accounts to ensure that each component has only the minimum permissions required to perform its functions. This reduces the potential attack surface and follows security best practices.

## Service Accounts

### 1. Terraform Deployer Service Account

This service account is used to deploy the infrastructure via Terraform.

**Roles:**
- `roles/compute.networkAdmin`: Manage VPC networks, subnets, firewall rules
- `roles/run.admin`: Create and manage Cloud Run services
- `roles/aiplatform.admin`: Set up Vertex AI resources
- `roles/iam.serviceAccountAdmin`: Create and manage service accounts
- `roles/iam.serviceAccountUser`: Use service accounts
- `roles/secretmanager.admin`: Manage secrets in Secret Manager
- `roles/resourcemanager.projectIamAdmin`: Manage IAM policies
- `roles/servicenetworking.serviceAgent`: Establish service networking connections
- `roles/vpcaccess.admin`: Create and manage VPC access connectors
- `roles/cloudkms.admin`: Manage KMS keys

**When to use:**
- Only during infrastructure deployment
- Should not be used by applications or for daily operations

### 2. Cloud Run Service Account

This service account is used by Cloud Run services to access other GCP resources.

**Custom Role Permissions:**
- `run.services.get`: Get information about Cloud Run services
- `run.services.invoke`: Call other Cloud Run services
- `aiplatform.endpoints.predict`: Make prediction requests to Vertex AI
- `aiplatform.models.predict`: Use Vertex AI models
- `secretmanager.versions.access`: Access Secret Manager secrets
- `logging.logEntries.create`: Write logs

**Additional Predefined Roles:**
- `roles/secretmanager.secretAccessor`: Access secrets
- `roles/logging.logWriter`: Write logs
- `roles/monitoring.metricWriter`: Write monitoring metrics

**When to use:**
- Attached to Cloud Run services
- Used for runtime operations within the application

### 3. Vertex AI Service Account

This service account is used by Vertex AI services.

**Custom Role Permissions:**
- `aiplatform.endpoints.predict`: Make prediction requests
- `aiplatform.models.predict`: Use AI models
- `aiplatform.models.get`: Get information about models
- `aiplatform.operations.get`: Get operation status
- `logging.logEntries.create`: Write logs

**Additional Predefined Roles:**
- `roles/aiplatform.serviceAgent`: Allow Vertex AI to act as a service
- `roles/logging.logWriter`: Write logs
- `roles/monitoring.metricWriter`: Write monitoring metrics

**When to use:**
- Attached to Vertex AI resources
- Used for AI model operations

### 4. GitHub Actions Service Account (Optional)

This service account is used for CI/CD operations via GitHub Actions.

**Roles:**
- `roles/storage.objectViewer`: Read access to GCS buckets
- `roles/artifactregistry.reader`: Read container images

**When to use:**
- Only during CI/CD pipeline execution
- Should have limited scope to specific resources

## Custom IAM Roles

### 1. Cloud Run Runtime Role (`cloudRunRuntime`)

A custom role with minimal permissions for Cloud Run services:
- Access to predict using Vertex AI endpoints and models
- Access to Secret Manager versions
- Ability to create log entries

### 2. Vertex AI Runtime Role (`vertexAiRuntime`)

A custom role with minimal permissions for Vertex AI operations:
- Predict using endpoints and models
- Get model information
- Get operation status
- Create log entries

## Resource-specific IAM Bindings

### 1. Cloud Run Service Access

The Cloud Run service account is granted the `roles/run.invoker` role on specific private Cloud Run services only, rather than at the project level.

### 2. Vertex AI Endpoint Access

Both service accounts are granted the `roles/aiplatform.user` role on specific Vertex AI endpoints only, limiting access to just the endpoints they need.

### 3. Secret Manager Access

Service accounts are granted access only to specific secrets they need, following the pattern:
```
Secret ID -> List of Service Accounts that need access
```

## Organization Policy Constraints

The following organization policy constraints should be applied to enhance security:

1. `iam.allowedPolicyMemberDomains`: Restrict to approved domains
2. `compute.requireOsLogin`: Enforce OS Login for VMs
3. `iam.disableServiceAccountKeyCreation`: Prevent service account key creation
4. `compute.restrictVpcPeering`: Limit VPC peering to approved projects

## Best Practices

1. **Rotation**: Regularly rotate service account credentials
2. **Auditing**: Enable audit logging for all IAM changes
3. **Review**: Periodically review permissions to ensure they're still necessary
4. **Workload Identity**: Use Workload Identity where possible instead of service account keys
5. **Monitoring**: Set up alerts for suspicious IAM activities

## How to Grant Additional Permissions

If additional permissions are required:

1. Update the `iam.tf` file
2. Add only the specific permission required
3. Document the reason for the addition
4. Apply changes through the established CI/CD pipeline
