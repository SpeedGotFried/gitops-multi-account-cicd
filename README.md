# GitOps-Driven CI/CD Platform (Single-Account Enterprise Pattern)

This project demonstrates a real-world enterprise DevOps setup using **GitOps principles**. It simulates a multi-environment architecture (Dev -> Prod) within a single AWS account, allowing you to practice advanced deployment patterns without the overhead of managing multiple AWS organizations.

## 🧩 Overview

- **One Git Repo**: Controls both Infrastructure as Code (IaC) and Application code.
- **Pipeline Strategy**: Promotes changes from `Dev` -> `Manual Approval` -> `Prod`.
- **Simulation**: Uses logical isolation (resource naming and tagging) to mimic multi-account boundaries.

## 🛠️ Tech Stack

- **Source Control**: GitHub
- **Orchestration**: AWS CodePipeline
- **Build & Test**: AWS CodeBuild
- **IaC**: Terraform
- **Compute**: AWS Lambda (Python)

## 🔥 Key Features

1.  **GitOps Workflow**: Infrastructure changes are applied automatically via Git commits.
2.  **Manual Approval Gates**: Critical production deployments require human intervention.
3.  **Automated Rollbacks**: (Planned) System automatically reverts if health checks fail.
4.  **Environment Isolation**: Distinct resources for Dev and Prod (e.g., `myapp-dev` vs `myapp-prod`) to prevent cross-contamination.

## 🚀 Getting Started

### Prerequisites
- AWS Account
- GitHub Repository
- AWS CLI configured locally

## 📂 Project Structure

```
├── infrastructure/     # Terraform code for pipeline and resources
├── src/               # Lambda application code
├── buildspecs/        # CodeBuild instruction files
└── README.md          # You are here
```

