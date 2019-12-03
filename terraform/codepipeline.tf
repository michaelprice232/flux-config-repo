resource "aws_codepipeline" "codepipeline" {
  name     = "${var.application_name}-pipeline"
  role_arn = aws_iam_role.iam_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration = {
        OAuthToken           = var.github_oauth_token
        Owner                = var.repo_owner
        Repo                 = var.repo_name
        Branch               = var.branch
        PollForSourceChanges = var.poll_source_changes
      }
    }
  }

  stage {
    name = "BuildDockerImage"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["code"]
      version         = "1"
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_docker_image.name
      }
    }
  }

  tags = {
    Name        = "codebuild_docker_image"
    Environment = var.environment
    Owner       = var.owner_name
  }
}