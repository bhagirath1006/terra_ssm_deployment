output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP Address (Elastic IP)"
  value       = aws_eip.web.public_ip
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.web.id
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.repo.repository_url
}

output "ecr_repository_name" {
  description = "ECR Repository Name"
  value       = aws_ecr_repository.repo.name
}

output "iam_role_arn" {
  description = "IAM Role ARN"
  value       = aws_iam_role.ec2.arn
}

output "website_url" {
  description = "Website URL"
  value       = "http://${aws_eip.web.public_ip}"
}

output "all_outputs" {
  description = "All important values"
  value = {
    instance_id      = aws_instance.web.id
    public_ip        = aws_eip.web.public_ip
    website_url      = "http://${aws_eip.web.public_ip}"
    ecr_repo         = aws_ecr_repository.repo.repository_url
    security_group   = aws_security_group.web.id
    iam_role         = aws_iam_role.ec2.arn
  }
}
