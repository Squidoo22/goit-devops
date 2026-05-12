terraform {
  backend "s3" {
    bucket         = "filimonov-serghei-terraform-state-bucket-afc2a520"
    key            = "lesson-7/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
