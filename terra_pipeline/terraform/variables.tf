variable "project_name" {
  default = "portfolio"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ssh_port" {
  default = 22
}

variable "http_port" {
  default = 80
}

variable "https_port" {
  default = 443
}

variable "app_port" {
  default = 3000
}

variable "allowed_cidr" {
  default = "0.0.0.0/0"
}

variable "enable_image_scanning" {
  default = true
}

variable "ecr_tag_immutability" {
  default = "MUTABLE"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "environment" {
  default = "production"
}

variable "tags" {
  type = map(string)
  default = {
    Terraform = "true"
    Project   = "portfolio"
  }
}
