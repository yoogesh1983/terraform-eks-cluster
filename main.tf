provider "aws" {
  profile = "terraform"
  region  = "us-east-2"
}  

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.21"
    }
  }
}

module "my-eks-cluster" {
  source = "./modules/02-eks"
}