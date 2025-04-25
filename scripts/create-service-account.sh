#!/bin/bash
# Script to create a service account with appropriate permissions for Terraform deployment
# Usage: ./create-service-account.sh PROJECT_ID [SERVICE_ACCOUNT_NAME]

if [ -z "$1" ]; then
    echo "Please provide a PROJECT_ID as the first argument"
    echo "Usage: ./create-service-account.sh PROJECT_ID [SERVICE_ACCOUNT_NAME]"
    exit 1
fi

PROJECT_ID=$1
SERVICE_ACCOUNT_NAME=${2:-"terraform-deployer"}
KEY_FILE="${SERVICE_ACCOUNT_NAME}-key.json"

echo "Creating service account for Terraform deployment in project: $PROJECT_ID"

# Create the service account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="Terraform Deployment Service Account" \
    --description="Service account for deploying infrastructure with Terraform" \
    --project=$PROJECT_ID

echo "Granting necessary permissions to service account..."

# Grant necessary roles to the service account
# These roles follow the principle of least privilege but allow for infrastructure deployment
ROLES=(
    "roles/compute.networkAdmin"
    "roles/run.admin"
    "roles/aiplatform.admin"
    "roles/iam.serviceAccountAdmin"
    "roles/iam.serviceAccountUser"
    "roles/secretmanager.admin"
    "roles/resourcemanager.projectIamAdmin"
    "roles/servicenetworking.serviceAgent"
    "roles/vpcaccess.admin"
    "roles/cloudkms.admin"
)

for ROLE in "${ROLES[@]}"; do
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
        --role="${ROLE}"
    echo "Granted ${ROLE} to service account"
done

# Create and download a service account key
echo "Creating and downloading service account key to ${KEY_FILE}..."
gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

echo "Done! Service account key has been saved to ${KEY_FILE}"
echo "--------------------------------------------------------"
echo "To use this service account with Terraform, set the GOOGLE_APPLICATION_CREDENTIALS environment variable:"
echo "export GOOGLE_APPLICATION_CREDENTIALS=\"$(pwd)/${KEY_FILE}\""
echo ""
echo "IMPORTANT: Keep this key file secure and consider rotating it regularly."
echo "Consider storing this key in a secure secret management solution."