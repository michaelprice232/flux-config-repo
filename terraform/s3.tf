resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.application_name}-artifacts"
  acl    = "private"

  tags = {
    Name        = "${var.application_name}-artifacts"
    Environment = var.environment
    Owner       = var.owner_name
  }
}