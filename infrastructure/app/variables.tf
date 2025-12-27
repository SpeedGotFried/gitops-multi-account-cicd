variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "gitops-app"
}

variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
}
