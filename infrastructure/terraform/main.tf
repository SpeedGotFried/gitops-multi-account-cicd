# -------------------------------------------------------------------------------------------------
# S3 Artifact Store
# -------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "artifact_store" {
  bucket = "${var.project_name}-artifact-store-${data.aws_caller_identity.current.account_id}"
}

data "aws_caller_identity" "current" {}

# -------------------------------------------------------------------------------------------------
# CodeStar Connection (GitHub)
# -------------------------------------------------------------------------------------------------
resource "aws_codestarconnections_connection" "github" {
  name          = "${var.project_name}-github-connection"
  provider_type = "GitHub"
}

# -------------------------------------------------------------------------------------------------
# CodeBuild Projects
# -------------------------------------------------------------------------------------------------

# Build/Plan Project
resource "aws_codebuild_project" "infrastructure_plan" {
  name          = "${var.project_name}-plan"
  description   = "Plan infrastructure changes"
  build_timeout = 5
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/plan.yml"
  }
}

# Apply Project
resource "aws_codebuild_project" "infrastructure_apply" {
  name          = "${var.project_name}-apply"
  description   = "Apply infrastructure changes"
  build_timeout = 5
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspecs/apply.yml"
  }
}

# -------------------------------------------------------------------------------------------------
# CodePipeline
# -------------------------------------------------------------------------------------------------
resource "aws_codepipeline" "pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_store.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_repo_owner}/${var.github_repo_name}"
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Plan"

    action {
      name             = "TerraformPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.infrastructure_plan.name
      }
    }
  }

  stage {
    name = "DeployDev"

    action {
      name             = "TerraformApplyDev"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.infrastructure_apply.name
        EnvironmentVariables = jsonencode([
          {
            name  = "TF_VAR_environment"
            value = "dev"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "Approval"

    action {
      name     = "ManualApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  stage {
    name = "DeployProd"

    action {
      name             = "TerraformApplyProd"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.infrastructure_apply.name
        EnvironmentVariables = jsonencode([
          {
            name  = "TF_VAR_environment"
            value = "prod"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }
}
