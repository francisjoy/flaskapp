terraform {
  backend "s3" {
    bucket         = "flaskapp-terraform-s3"
    key            = "eks/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
