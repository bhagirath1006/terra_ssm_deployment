#!/bin/bash
# Initialize Terraform and prepare for deployment

echo "================================"
echo "Terraform Portfolio Pipeline Setup"
echo "================================"

cd terraform

echo ""
echo "Step 1: Initializing Terraform..."
terraform init

echo ""
echo "Step 2: Validating Terraform configuration..."
terraform validate

echo ""
echo "Step 3: Formatting Terraform files..."
terraform fmt -recursive

echo ""
echo "Step 4: Creating Terraform Plan..."
terraform plan -out=tfplan

echo ""
echo "================================"
echo "✓ Setup Complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Review the plan above"
echo "2. Run: terraform apply tfplan"
echo "3. Wait for EC2 and ECR to be created"
echo "4. Add GitHub secrets:"
echo "   - VAULT_ADDR"
echo "   - AWS_ACCOUNT_ID"
echo "5. Push to GitHub to trigger deployment"
echo ""
