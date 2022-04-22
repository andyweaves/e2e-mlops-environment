variable "databricks_account_username" {
    description = "Please enter your Databricks account username. This will be used to create Databricks workspaces and related objects on your behalf."
    type = string
    sensitive = true
}

variable "databricks_account_password" {
    description = "Please enter your Databricks account password. This will be used to create Databricks workspaces and related objects on your behalf."
    type = string
    sensitive = true
}

variable "databricks_account_id" {
    description = "Please enter your Databricks account id. This will be used to create Databricks workspaces and related objects on your behalf."
    type = string
    sensitive = true
}

variable "nonprod_cross_account_role_arn" {
    description = "Please enter the AWS IAM Role ARN for the NON-PRODUCTION Databricks cross account role"
    type = string
    sensitive = true
}

variable "prod_cross_account_role_arn" {
    description = "Please enter the AWS IAM Role ARN for the PRODUCTION Databricks cross account role"
    type = string
    sensitive = true
}

variable "region" {
  default = "eu-west-2"
}

variable "tags" {
  default = {
      Owner = "andrew.weaver@databricks.com"
  }
}

variable "vpc_cidr_block" {
  default = "10.4.0.0/16"
}