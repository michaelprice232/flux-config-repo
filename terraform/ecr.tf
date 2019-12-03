# ECR Docker Repository
resource "aws_ecr_repository" "app_repo" {
  name = var.application_name

  tags = {
    Name        = var.application_name
    Environment = var.environment
    Owner       = var.owner_name
  }
}