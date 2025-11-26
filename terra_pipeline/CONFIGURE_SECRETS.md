# Step-by-Step: Configure GitHub Secrets

Your code is now pushed to GitHub! Now follow these steps to configure secrets.

## Step 1: Get Your AWS Account ID

1. Go to: https://console.aws.amazon.com
2. Click your username (top right)
3. Click "Security credentials"
4. Find "Account ID" at the top (12 digits)
5. Copy it

Example: `123456789012`

## Step 2: Add GitHub Secrets

### Option A: Via GitHub Web UI (Easiest)

1. Go to your GitHub repository: https://github.com/bhagirath1006/cloudnexus-web-2
2. Click **Settings** (top right)
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**

### Add Secret #1: AWS_ACCOUNT_ID

- **Name**: `AWS_ACCOUNT_ID`
- **Value**: Paste your 12-digit AWS Account ID
- Click **Add secret**

### Add Secret #2: VAULT_ADDR

- **Name**: `VAULT_ADDR`
- **Value**: Your Vault URL (e.g., `https://vault.example.com`)
- Click **Add secret**

**If you don't have Vault yet**, use a placeholder for now:
```
https://vault.hashicorp.cloud
```

### Verify Secrets Added

After adding both secrets, you should see:
```
AWS_ACCOUNT_ID    [Updated less than a minute ago]
VAULT_ADDR        [Updated less than a minute ago]
```

## Step 3: Create AWS IAM User

Now create AWS credentials for GitHub Actions:

1. Go to: https://console.aws.amazon.com/iam
2. Click **Users** (left sidebar)
3. Click **Create user**
   - Name: `github-actions`
   - Click **Create user**

4. Click on the new user
5. Click **Security credentials** tab
6. Click **Create access key**
7. Select **Application running outside AWS**
8. Click **Create access key**
9. Copy both:
   - Access Key ID
   - Secret Access Key

**Keep these safe!** You'll store them in Vault next.

## Step 4: Attach AWS Permissions

For the `github-actions` user, attach these policies:

1. Still in IAM Users page
2. Click on `github-actions` user
3. Click **Add permissions** → **Attach policies directly**
4. Search and check these policies:
   - `AmazonEC2FullAccess`
   - `AmazonECRFullAccess`
   - `IAMReadOnlyAccess`

5. Click **Attach policies**

## Step 5: Set Up HashiCorp Vault

### Option A: Use HashiCorp Cloud (Free)

1. Go to: https://app.terraform.io/signup
2. Sign up for free
3. Create a new Vault instance
4. Note your Vault URL

### Option B: Run Vault Locally (Docker)

```bash
docker run -d -p 8200:8200 vault:latest
export VAULT_ADDR='http://localhost:8200'
vault operator init
vault operator unseal
```

### Store AWS Credentials in Vault

1. Log into your Vault:
```bash
vault login  # or vault operator unseal, then vault login
```

2. Store the credentials:
```bash
vault kv put secret/aws/credentials \
  access_key=YOUR_ACCESS_KEY_ID \
  secret_key=YOUR_SECRET_ACCESS_KEY
```

3. Verify it was stored:
```bash
vault kv get secret/aws/credentials
```

Output should look like:
```
===== Secret Path =====
secret/data/aws/credentials

===== Metadata =====
Key                Value
---                ----
created_time       2025-11-26T10:00:00Z
deletion_time      n/a
destroyed          false
version            1

===== Data =====
Key               Value
---               -----
access_key        AKIA...
secret_key        wJal...
```

## Step 6: Configure Vault JWT for GitHub

Enable JWT authentication in Vault:

```bash
# Enable JWT auth
vault auth enable jwt

# Configure GitHub OIDC
vault write auth/jwt/config \
  jwks_url="https://token.actions.githubusercontent.com/.well-known/jwks" \
  bound_audiences="https://github.com/bhagirath1006"

# Create role for GitHub Actions
vault write auth/jwt/role/github-actions \
  bound_audiences="https://github.com/bhagirath1006" \
  user_claim="actor" \
  role_type_claim="iss" \
  policies="default"
```

## Step 7: Update GitHub Secrets with Real Vault URL

Go back to GitHub Secrets:
1. Click **Settings** → **Secrets and variables** → **Actions**
2. Click on `VAULT_ADDR` → **Update secret**
3. Enter your real Vault URL:
   ```
   https://vault.yourdomain.com  (or HashiCorp Cloud URL)
   ```
4. Click **Update secret**

## Step 8: Test the Pipeline

1. Go to your GitHub repository
2. Click **Actions**
3. You should see your workflow file
4. Make a small change to test:
   ```bash
   git add .
   git commit -m "Update secrets configuration"
   git push origin feature/bhagirath
   ```

5. GitHub Actions should trigger automatically
6. Watch the workflow run in the Actions tab

## Troubleshooting

### Secrets not showing in workflow?
- Wait 5 minutes after adding secrets
- Refresh the page
- Try committing again

### Vault connection fails?
- Check VAULT_ADDR is correct
- Verify Vault is running
- Check JWT configuration

### AWS credentials rejected?
- Verify credentials are correct in Vault
- Check IAM user has proper permissions
- Ensure access key is active (not deleted)

## Next Steps

1. ✅ Push code to GitHub
2. ✅ Configure GitHub Secrets (AWS_ACCOUNT_ID, VAULT_ADDR)
3. ✅ Create AWS IAM user (github-actions)
4. ✅ Store AWS credentials in Vault
5. ⏭️ Deploy infrastructure: `terraform apply`
6. ⏭️ Push to trigger deployment

## Command Reference

```bash
# Check secrets in Vault
vault kv list secret/
vault kv get secret/aws/credentials

# Update secret
vault kv put secret/aws/credentials \
  access_key=NEW_KEY \
  secret_key=NEW_SECRET

# Test GitHub Actions locally
act -j build  # Requires 'act' tool
```

## Security Notes

- Never commit AWS credentials
- Rotate credentials every 90 days
- Use separate credentials for different services
- Enable MFA on AWS account
- Monitor CloudTrail for unusual activity

---

**Done!** Your secrets are configured. 

Next: Run `terraform apply` to deploy your infrastructure.
