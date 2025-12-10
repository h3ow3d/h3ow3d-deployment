terraform {
  backend "s3" {
    bucket  = "patch-notes-tfstate-575108940418"
    key     = "h3ow3d/deployment/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}
