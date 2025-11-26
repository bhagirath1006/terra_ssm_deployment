# Portfolio Auto-Deploy Pipeline

Automatic deployment of your portfolio website using GitHub Actions, Terraform, Docker, and AWS.

**Every push to GitHub → Automatic build, test, and deployment to live server**

## Architecture

```
GitHub Repository
    ↓
GitHub Actions (Triggered on push)
    ↓
Build Docker Image
    ↓
Push to AWS ECR
    ↓
SSH to EC2 via AWS SSM
    ↓
Pull latest image and run container
    ↓
Live website available at elastic IP
```

## Prerequisites

- AWS Account (free tier eligible)
- GitHub Account with this repository
- HashiCorp Vault instance (for credentials)
- Docker installed locally (for testing)

## File Structure

```
terra_pipeline/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions workflow
├── terraform/
│   ├── main.tf                 # EC2, Security Group, IAM, ECR
│   ├── provider.tf             # AWS provider config
│   ├── variables.tf            # All configurable variables
│   ├── outputs.tf              # Output values
│   ├── backend.tf              # S3 state storage config
│   ├── terraform.tfvars        # Default values
│   └── user-data.sh            # EC2 setup script
├── portfolio/
│   ├── Dockerfile              # Container definition
│   ├── package.json            # Node.js dependencies
│   ├── server.js               # Web server code
├── Dockerfile                  # Main app Dockerfile
├── README.md                   # This file
├── SECRETS_SETUP.md           # Secrets configuration
├── init.sh                    # Quick setup script
└── .gitignore                 # Git ignore rules
```

## Quick Start (5 minutes)

### Step 1: Clone Repository
```bash
git clone <your-repo-url>
cd terra_pipeline
```

### Step 2: Configure AWS & Vault Secrets
See `SECRETS_SETUP.md` for detailed instructions

Add these GitHub repository secrets:
- `AWS_ACCOUNT_ID`: Your AWS account ID
- `VAULT_ADDR`: Your Vault URL

### Step 3: Customize Configuration
Edit `terraform/terraform.tfvars`:
```hcl
project_name = "portfolio"
instance_type = "t2.micro"      # Free tier
aws_region = "us-east-1"
environment = "production"

# Security
ssh_port = 22
http_port = 80
https_port = 443
app_port = 3000
allowed_cidr = "0.0.0.0/0"      # Restrict this if needed
```

### Step 4: Initialize Terraform
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This creates:
- EC2 instance (t2.micro - free tier)
- Security group with SSH, HTTP, HTTPS
- ECR repository for Docker images
- IAM roles with minimal permissions
- Elastic IP for static access

### Step 5: Get Your Server IP
```bash
terraform output public_ip
```

Visit: `http://<your-public-ip>`

### Step 6: Deploy Website
Just push to GitHub!
```bash
git add .
git commit -m "Deploy portfolio"
git push origin main
```

GitHub Actions automatically:
1. Builds Docker image
2. Pushes to ECR
3. Deploys to EC2
4. Your website is live!

## How It Works

### GitHub Actions Workflow

When you push to `main` or `develop`:

1. **Build Stage**: Docker image created from `portfolio/Dockerfile`
2. **Push Stage**: Image pushed to AWS ECR
3. **Deploy Stage**: 
   - Retrieves AWS credentials from HashiCorp Vault
   - Uses AWS SSM to execute commands on EC2
   - Pulls latest Docker image
   - Stops old container
   - Starts new container on port 80
4. **Live**: Website accessible immediately

### Terraform Infrastructure

**Networking:**
- Security Group allows SSH (22), HTTP (80), HTTPS (443)
- App runs on port 3000, exposed via port 80

**Compute:**
- EC2 instance (t2.micro = free tier)
- Amazon Linux 2 with Docker pre-installed
- IAM role for ECR and Secrets Manager access

**Container Registry:**
- ECR repository auto-scans images
- Stores Docker images with automatic cleanup

**Identity & Access:**
- IAM role for EC2 with minimal permissions
- Vault integration for secure credentials

## Customization

### Change Instance Type
Edit `terraform/terraform.tfvars`:
```hcl
instance_type = "t3.small"  # More powerful
```

### Allow SSH from Specific IP
```hcl
allowed_cidr = "YOUR_IP/32"  # Only your IP
```

### Update Portfolio Code
1. Edit files in `portfolio/` directory
2. Git push
3. Automatic deployment happens

### Add Environment Variables
In `.github/workflows/deploy.yml`, add to deploy step:
```yaml
--parameters 'commands=["export MY_VAR=value","docker run ..."]'
```

## Troubleshooting

### Website not loading?
```bash
# Get instance ID
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=portfolio-server" \
  --query 'Reservations[0].Instances[0].InstanceId'

# Check container status via SSM
aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --instance-ids "<instance-id>" \
  --parameters 'commands=["docker ps"]'
```

### GitHub Actions failing?
1. Check workflow logs: Repository → Actions → Latest run
2. Verify GitHub secrets are set correctly
3. Check Vault credentials are accessible
4. Review AWS IAM permissions

### Terraform errors?
```bash
cd terraform
terraform validate      # Check syntax
terraform plan         # See what will happen
terraform destroy      # Clean up resources
```

### Docker image not building?
Check `portfolio/Dockerfile` for syntax errors:
```bash
docker build -t test-portfolio ./portfolio
```

## Cost Estimate

**Monthly cost: ~$3-5 (within AWS free tier)**
- EC2 t2.micro: Free for first year
- Data transfer: ~1GB free tier
- ECR storage: $0.10 per GB
- S3 state file: <$0.01

## Monitoring

Check deployment logs:
```bash
# GitHub Actions logs
# Go to: Repository → Actions → Deploy Portfolio

# EC2 logs via SSM
aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --instance-ids "<instance-id>" \
  --parameters 'commands=["docker logs portfolio-container"]'
```

## Security Best Practices

1. **Restrict SSH Access**:
   Edit `terraform/terraform.tfvars`:
   ```hcl
   allowed_cidr = "YOUR_IP/32"
   ```

2. **Use IAM Roles**: Never use root AWS credentials
   - Already configured in this setup

3. **Enable Vault Encryption**: 
   - Set `encrypt = true` in `backend.tf`

4. **Rotate Secrets Regularly**:
   - Update Vault credentials every 90 days

5. **Monitor Costs**:
   - Set AWS billing alerts
   - Use CloudWatch for monitoring

## Advanced Usage

### Multiple Environments
Create separate `.tfvars` files:
```bash
terraform apply -var-file="staging.tfvars"
terraform apply -var-file="production.tfvars"
```

### Custom Domain
Add Route53 DNS:
```hcl
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "portfolio.example.com"
  type    = "A"
  alias {
    name                   = aws_eip.web.public_ip
    zone_id                = aws_eip.web.zone_id
    evaluate_target_health = false
  }
}
```

### Auto-Scaling
Modify `main.tf` to add:
- Auto Scaling Group
- Application Load Balancer
- CloudWatch alarms

## Support & Documentation

- **Terraform Docs**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **GitHub Actions**: https://docs.github.com/en/actions
- **HashiCorp Vault**: https://www.vaultproject.io/docs
- **AWS EC2**: https://docs.aws.amazon.com/ec2/

## License

MIT License - Feel free to use and modify

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes
4. Push and create a pull request

---

**Ready? Let's deploy!** 🚀

```bash
cd terraform
terraform init
terraform apply
git push origin main
```

Your website will be live in minutes!
