#terraform {
#  backend "s3" {
#    bucket         = "filimonov-serghei-terraform-state-bucket-afc2a520"
#    key            = "lesson-5/terraform.tfstate"
#    region         = "us-west-2"
#    dynamodb_table = "terraform-locks"
#    encrypt        = true
#  }
#}
