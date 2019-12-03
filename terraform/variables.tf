variable "region" {
  description = "Which AWS region are we deploying to?"
  default     = "eu-west-2"
}

variable "environment" {
  description = "Which environment are we deploying to? Used for AWS tagging and is also passed as an ENVAR to the build pipeline"
}

variable "application_name" {
  description = "What is the application called? The CodePipeline, S3 bucket and ECR repo get created based on this name"
}

variable "repo_owner" {
  description = "GitHub Organization or Person name containing the application git repo"
}

variable "repo_name" {
  description = "GitHub repository name of the application to be built"
}

variable "branch" {
  description = "Branch of the GitHub repository"
  default     = "master"
}

variable "poll_source_changes" {
  default     = "true"
  description = "Periodically check the location of your source content and run the pipeline if changes are detected"
}

variable "github_oauth_token" {
  description = "GitHub Oauth Token with permissions to access private repositories"
}

variable "owner_name" {
  description = "The name to add to the owner field on all the AWS resource tags"
}

