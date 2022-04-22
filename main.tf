provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
    prefix = "mlops-${random_string.naming.result}"
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

output "aws_user" {
  value = data.aws_caller_identity.current.arn
}

output "aws_account_id" {
  value = local.account_id
}

output "resource_prefix" {
  value = local.prefix
}

output "databricks_nonprod_url" {
  value = databricks_mws_workspaces.nonprod.workspace_url
}

output "databricks_prod_url" {
  value = databricks_mws_workspaces.prod.workspace_url
}

output "databricks_nonprod_token" {
  value     = databricks_mws_workspaces.nonprod.token[0].token_value
  sensitive = true
}

output "databricks_prod_token" {
  value     = databricks_mws_workspaces.prod.token[0].token_value
  sensitive = true
}