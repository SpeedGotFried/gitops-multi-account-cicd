variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "gitops-cicd"
}

variable "github_repo_owner" {
  description = "GitHub Repository Owner"
  type        = string
  default     = "SpeedGotFried"
}

variable "github_repo_name" {
  description = "GitHub Repository Name"
  type        = string
  default     = "gitops-multiacct-cicd"
}

variable "github_branch" {
  description = "GitHub Branch to track"
  type        = string
  default     = "main"
}
