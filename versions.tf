terraform {
  required_version = ">= 0.13.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.33.0"
    }
  }
}
