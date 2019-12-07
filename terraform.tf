terraform {
  required_version = ">= 0.12"
  # backend "s3" {
  #   encrypt = "true"
  #   bucket  = "terraform-state-nexus-user-conference"
  #   region  = "us-east-1"
  #   key     = "jenkins/terraform.tfstate"
  # }
}

provider "aws" {
  region                  = "${var.region}"  
  profile                 = "${var.aws_profile}"
}
