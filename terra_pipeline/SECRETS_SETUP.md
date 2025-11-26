# GitHub Secrets Setup Guide

## Required GitHub Secrets

Add these secrets to your GitHub repository:

### AWS Credentials
```
Name: AWS_ACCOUNT_ID
Value: <your-12-digit-aws-account-id>
Example: 123456789012
```

### HashiCorp Vault
```
Name: VAULT_ADDR
Value: https://vault.example.com
```

### GitHub Environment Variables (in workflow)
These are already configured in `.github/workflows/deploy.yml`:
- `AWS_REGION`: us-east-1
- `ECR_REPO`: portfolio-repo

## How to Add Secrets

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret one by one

## Vault Secrets Required

Store these in your HashiCorp Vault:

```
Path: secret/data/aws/credentials
Fields:
  - access_key: <your-aws-access-key>
  - secret_key: <your-aws-secret-key>
```

## Testing Vault Connection

```bash
# Log in to your Vault
vault login

# Check if secrets exist
vault kv get secret/aws/credentials
```

## AWS IAM User Setup

The AWS credentials should belong to a user with these permissions:
- AmazonEC2FullAccess
- AmazonECRFullAccess
- IAMReadOnlyAccess
- Systems Manager (SSM) access

## GitHub Actions JWT Setup

For JWT authentication with Vault:

1. Enable JWT auth in Vault
2. Configure GitHub OIDC
3. Create a role in Vault for GitHub Actions

```bash
vault auth enable jwt

vault write auth/jwt/config \
  jwks_url="https://token.actions.githubusercontent.com/.well-known/jwks" \
  bound_audiences="https://github.com/your-org"

vault write auth/jwt/role/github-actions \
  bound_audiences="https://github.com/your-org" \
  user_claim="actor" \
  role_type_claim="iss" \
  policies="default"
```

Done! Your secrets are ready.
