#!/bin/bash
# Script to enable all required GCP APIs for Cloud Run with Vertex AI integration
# Usage: ./enable-apis.sh PROJECT_ID

if [ -z "$1" ]; then
    echo "Please provide a PROJECT_ID as the first argument"
    echo "Usage: ./enable-apis.sh PROJECT_ID"
    exit 1
fi

PROJECT_ID=$1
echo "Enabling required APIs for project: $PROJECT_ID"

# Core APIs
echo "Enabling core APIs..."
gcloud services enable compute.googleapis.com --project=$PROJECT_ID               # Compute Engine API
gcloud services enable servicenetworking.googleapis.com --project=$PROJECT_ID     # Service Networking API
gcloud services enable run.googleapis.com --project=$PROJECT_ID                   # Cloud Run API
gcloud services enable aiplatform.googleapis.com --project=$PROJECT_ID            # Vertex AI API
gcloud services enable secretmanager.googleapis.com --project=$PROJECT_ID         # Secret Manager API
gcloud services enable iam.googleapis.com --project=$PROJECT_ID                   # IAM API

# Additional required APIs
echo "Enabling additional APIs..."
gcloud services enable cloudkms.googleapis.com --project=$PROJECT_ID              # Cloud KMS API
gcloud services enable vpcaccess.googleapis.com --project=$PROJECT_ID             # Serverless VPC Access API
gcloud services enable notebooks.googleapis.com --project=$PROJECT_ID             # Notebooks API
gcloud services enable accesscontextmanager.googleapis.com --project=$PROJECT_ID  # Access Context Manager API
gcloud services enable securitycenter.googleapis.com --project=$PROJECT_ID        # Security Command Center API

# Networking APIs
echo "Enabling networking APIs..."
gcloud services enable dns.googleapis.com --project=$PROJECT_ID                   # Cloud DNS API
gcloud services enable networkconnectivity.googleapis.com --project=$PROJECT_ID   # Network Connectivity API

# For Windows systems, create a batch equivalent
cat > enable-apis.bat << EOF
@echo off
REM Script to enable all required GCP APIs for Cloud Run with Vertex AI integration
REM Usage: enable-apis.bat PROJECT_ID

if "%1"=="" (
    echo Please provide a PROJECT_ID as the first argument
    echo Usage: enable-apis.bat PROJECT_ID
    exit /b 1
)

set PROJECT_ID=%1
echo Enabling required APIs for project: %PROJECT_ID%

REM Core APIs
echo Enabling core APIs...
call gcloud services enable compute.googleapis.com --project=%PROJECT_ID%
call gcloud services enable servicenetworking.googleapis.com --project=%PROJECT_ID%
call gcloud services enable run.googleapis.com --project=%PROJECT_ID%
call gcloud services enable aiplatform.googleapis.com --project=%PROJECT_ID%
call gcloud services enable secretmanager.googleapis.com --project=%PROJECT_ID%
call gcloud services enable iam.googleapis.com --project=%PROJECT_ID%

REM Additional required APIs
echo Enabling additional APIs...
call gcloud services enable cloudkms.googleapis.com --project=%PROJECT_ID%
call gcloud services enable vpcaccess.googleapis.com --project=%PROJECT_ID%
call gcloud services enable notebooks.googleapis.com --project=%PROJECT_ID%
call gcloud services enable accesscontextmanager.googleapis.com --project=%PROJECT_ID%
call gcloud services enable securitycenter.googleapis.com --project=%PROJECT_ID%

REM Networking APIs
echo Enabling networking APIs...
call gcloud services enable dns.googleapis.com --project=%PROJECT_ID%
call gcloud services enable networkconnectivity.googleapis.com --project=%PROJECT_ID%

echo All required APIs have been enabled for project: %PROJECT_ID%
EOF

echo "All required APIs have been enabled for project: $PROJECT_ID"
echo "A Windows batch file (enable-apis.bat) has also been created."