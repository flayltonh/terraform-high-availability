terraform {
  backend "s3" {
    bucket         = "terraform-state-projeto-aws-high-availability"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-id"
    encrypt        = true
  }
}
