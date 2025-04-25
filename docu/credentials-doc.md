# Secure Credentials Management

This document outlines best practices for managing GCP credentials securely in the context of this project.

## GCP Service Account Credentials

### Creating Service Account Credentials

The repository provides scripts to create a service account with appropriate permissions:

```bash
# For Linux/Mac
./scripts/create-service-account.sh PROJECT_ID [SERVICE_ACCOUNT_NAME]

# For Windows
scripts\create-service-account.bat PROJECT_ID [SERVICE_ACCOUNT_NAME]
```

These scripts will:
1. Create a service account
2. Grant necessary permissions following the least privilege principle
3. Generate a JSON key file

### Setting Up Credentials for Terraform

#### Local Development

For local development, set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable:

```bash
# Linux/Mac
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"

# Windows Command Prompt
set GOOGLE_APPLICATION_CREDENTIALS=C:\path\to\service-account-key.json

# Windows PowerShell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\service-account-key.json"
```

Alternatively, for local development, you can use your user credentials:

```bash
gcloud auth application-default login
```

#### CI/CD Pipelines

For GitHub Actions, store the credentials as a secret:

1. Go to your GitHub repository
2. Navigate to Settings > Secrets > Actions
3. Add a new repository secret named `GOOGLE_CREDENTIALS`
4. Paste the entire content of the JSON key file

In your workflow YAML, reference it like this:

```yaml
- name: 'Authenticate to Google Cloud'
  uses: 'google-github-actions/auth@v1'
  with:
    credentials_json: '${{ secrets.GOOGLE_CREDENTIALS }}'
```

## Alternatives to Service Account Keys

Service account keys should be used cautiously as they represent long-lived credentials. Consider these alternatives:

### Workload Identity Federation (Recommended for CI/CD)

For GitHub Actions, you can use Workload Identity Federation:

1. Set up Workload Identity Federation in GCP
2. Configure your GitHub Actions workflow:

```yaml
- name: 'Authenticate to Google Cloud'
  uses: 'google-github-actions/auth@v1'
  with:
    workload_identity_provider: 'projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github-provider'
    service_account: 'terraform-deployer@your-project-id.iam.gserviceaccount.com'
```

### Attached Service Accounts (Recommended for Production)

For Cloud Run services, don't use keys. Instead, attach service accounts:

```terraform
resource "google_cloud_run_service" "service" {
  # ...
  template {
    spec {
      service_account_name = google_service_account.cloud_run_sa.email
      # ...
    }
  }
}
```

## Security Best Practices

### Key Management

- **Store securely**: Keep keys in a secure location, never in code
- **Rotation**: Rotate keys every 90 days or sooner
- **Expiration**: Set expiration dates on keys when possible
- **Revocation**: Revoke unused or compromised keys immediately

### Access Control

- **Principle of least privilege**: Grant minimal permissions
- **Separation of concerns**: Use different service accounts for different components
- **Just-in-time access**: Grant temporary elevated permissions when needed

### Auditing and Monitoring

- Enable audit logging for service account activity:

```bash
gcloud logging sinks create sa-audit-sink storage.googleapis.com/your-audit-bucket \
  --log-filter='protoPayload.serviceName="iam.googleapis.com" AND protoPayload.methodName="google.iam.admin.v1.CreateServiceAccountKey"'
```

- Set up alerts for suspicious activity:

```bash
gcloud alpha monitoring policies create \
  --display-name="Service Account Key Creation Alert" \
  --condition-filter='resource.type="service_account" AND protoPayload.methodName="google.iam.admin.v1.CreateServiceAccountKey"'
```

## Environment-Specific Recommendations

### Development

- Use temporary credentials where possible
- Personal developer accounts with appropriate IAM roles
- Store test secrets in environment-specific Secret Manager instances

### Production

- Never use local key files
- Implement key rotation automation
- Use more restrictive IAM policies
- Consider using VPC Service Controls to restrict API access
- Implement detection for leaked credentials

## In Case of Credential Leakage

If credentials are accidentally leaked:

1. **Immediate Action**:
   - Revoke the leaked key: `gcloud iam service-accounts keys delete KEY_ID --iam-account=SA_EMAIL`
   - Audit actions performed using the key

2. **Investigation**:
   - Determine how the leak occurred
   - Review access logs for suspicious activity

3. **Prevention**:
   - Implement additional safeguards based on findings
   - Conduct team training if necessary
