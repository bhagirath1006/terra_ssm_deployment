# ✅ Pipeline Setup Checklist

## Phase 1: GitHub Push ✅ DONE
- [x] Code pushed to GitHub
- [x] All files committed
- [x] Branch: `feature/bhagirath`

## Phase 2: Configure Secrets (DO THIS NOW)

### Step 1: Get AWS Account ID
- [ ] Go to: https://console.aws.amazon.com
- [ ] Find your Account ID (12 digits)
- [ ] Copy it

### Step 2: Add GitHub Secrets
Go to: https://github.com/bhagirath1006/cloudnexus-web-2/settings/secrets/actions

Add these 2 secrets:

#### Secret 1: AWS_ACCOUNT_ID
- [ ] Name: `AWS_ACCOUNT_ID`
- [ ] Value: `<your-12-digit-id>`
- [ ] Click "Add secret"

#### Secret 2: VAULT_ADDR
- [ ] Name: `VAULT_ADDR`
- [ ] Value: `https://vault.example.com` (or HashiCorp Cloud URL)
- [ ] Click "Add secret"

### Step 3: Create AWS IAM User
Go to: https://console.aws.amazon.com/iam/home#/users

- [ ] Create user: `github-actions`
- [ ] Generate Access Keys
- [ ] Copy Access Key ID
- [ ] Copy Secret Access Key
- [ ] Attach policies:
  - [ ] AmazonEC2FullAccess
  - [ ] AmazonECRFullAccess
  - [ ] IAMReadOnlyAccess

### Step 4: Set Up Vault
Choose one:

#### Option A: HashiCorp Cloud (Easiest)
- [ ] Sign up: https://app.terraform.io/signup
- [ ] Create Vault instance
- [ ] Get Vault URL
- [ ] Update GitHub secret `VAULT_ADDR`

#### Option B: Docker (Local)
```bash
docker run -d -p 8200:8200 vault:latest
vault operator init
vault operator unseal
```

### Step 5: Store Credentials in Vault
```bash
vault kv put secret/aws/credentials \
  access_key=YOUR_ACCESS_KEY_ID \
  secret_key=YOUR_SECRET_ACCESS_KEY
```

- [ ] Credentials stored in Vault
- [ ] Can retrieve with: `vault kv get secret/aws/credentials`

### Step 6: Enable JWT Auth (If using Vault)
```bash
vault auth enable jwt
vault write auth/jwt/config \
  jwks_url="https://token.actions.githubusercontent.com/.well-known/jwks" \
  bound_audiences="https://github.com/bhagirath1006"
vault write auth/jwt/role/github-actions \
  bound_audiences="https://github.com/bhagirath1006" \
  user_claim="actor" \
  role_type_claim="iss" \
  policies="default"
```

- [ ] JWT auth configured
- [ ] GitHub Actions role created

## Phase 3: Deploy Infrastructure

### Step 1: Initialize Terraform
```bash
cd terraform
terraform init
```
- [ ] Terraform initialized

### Step 2: Create Plan
```bash
terraform plan -out=tfplan
```
- [ ] Plan created
- [ ] No errors shown

### Step 3: Apply
```bash
terraform apply tfplan
```
- [ ] EC2 instance created
- [ ] ECR repository created
- [ ] Security groups configured
- [ ] IAM roles set up

### Step 4: Get Output
```bash
terraform output
```
- [ ] Public IP: `_______________`
- [ ] ECR URL: `_______________`
- [ ] Instance ID: `_______________`

## Phase 4: Deploy Website

### Step 1: Test Local
```bash
cd portfolio
npm install
npm start
```
- [ ] Website runs on http://localhost:3000

### Step 2: Push to GitHub
```bash
git add .
git commit -m "Initial portfolio"
git push origin feature/bhagirath
```
- [ ] Code pushed

### Step 3: Watch GitHub Actions
Go to: https://github.com/bhagirath1006/cloudnexus-web-2/actions

- [ ] Workflow triggered
- [ ] Docker image built
- [ ] Pushed to ECR
- [ ] Deployed to EC2

### Step 4: Visit Website
```
http://<your-public-ip>
```
- [ ] Website is live! 🎉

## Troubleshooting

### Secrets not working?
```bash
# Check what's in GitHub
# Settings → Secrets and variables → Actions
# Should see both secrets listed
```

### Vault connection failing?
```bash
# Test Vault connection
curl -k https://vault.example.com/v1/sys/health
```

### Terraform errors?
```bash
terraform validate
terraform fmt
terraform plan
```

### GitHub Actions failing?
- Check Actions tab for logs
- Look for error messages
- Verify AWS credentials in Vault

## Quick Links

- GitHub Repo: https://github.com/bhagirath1006/cloudnexus-web-2
- GitHub Secrets: https://github.com/bhagirath1006/cloudnexus-web-2/settings/secrets/actions
- AWS Console: https://console.aws.amazon.com
- AWS IAM: https://console.aws.amazon.com/iam
- Vault Cloud: https://app.terraform.io

## Getting Help

1. Check CONFIGURE_SECRETS.md for detailed steps
2. Check SECRETS_SETUP.md for Vault details
3. Check README.md for architecture
4. Review GitHub Actions logs for errors

---

**Current Status**: Code pushed to GitHub ✅

**Next Step**: Configure GitHub Secrets

**Estimated Time**: 15-20 minutes
