terraform {
  required_providers {
    databricks = {
      source = "databrickslabs/databricks"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}