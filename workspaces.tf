provider "databricks" {
  alias    = "mws"
  host     = "https://accounts.cloud.databricks.com"
  username = var.databricks_account_username
  password = var.databricks_account_password
}

resource "databricks_mws_credentials" "nonprod" {
  provider         = databricks.mws
  account_id       = var.databricks_account_id
  role_arn         = var.nonprod_cross_account_role_arn
  credentials_name = "nonprod-${local.prefix}-cross-account-role"
}

resource "databricks_mws_credentials" "prod" {
  provider         = databricks.mws
  account_id       = var.databricks_account_id
  role_arn         = var.prod_cross_account_role_arn
  credentials_name = "prod-${local.prefix}-cross-account-role"
}

resource "databricks_mws_storage_configurations" "nonprod" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.nonprod_root_bucket.bucket
  storage_configuration_name = "nonprod-${local.prefix}-rootbucket"
}

resource "databricks_mws_storage_configurations" "prod" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.prod_root_bucket.bucket
  storage_configuration_name = "prod-${local.prefix}-rootbucket"
}

resource "databricks_mws_networks" "nonprod" {
  depends_on         = [aws_vpc.nonprod_vpc, aws_security_group.nonprod_sg, aws_subnet.nonprod_private_subnets]
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "nonprod-${local.prefix}-dataplane"
  security_group_ids = [aws_security_group.nonprod_sg.id]
  subnet_ids         = "${aws_subnet.nonprod_private_subnets.*.id}" 
  vpc_id             = aws_vpc.nonprod_vpc.id
}

resource "databricks_mws_networks" "prod" {
  depends_on         = [aws_vpc.prod_vpc, aws_security_group.prod_sg, aws_subnet.prod_private_subnets]
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "prod-${local.prefix}-dataplane"
  security_group_ids = [aws_security_group.prod_sg.id]
  subnet_ids         = "${aws_subnet.prod_private_subnets.*.id}" 
  vpc_id             = aws_vpc.prod_vpc.id
}

resource "databricks_mws_workspaces" "nonprod" {
  provider        = databricks.mws
  account_id      = var.databricks_account_id
  aws_region      = var.region
  workspace_name  = "nonprod-${local.prefix}"
  deployment_name = "nonprod-${local.prefix}"

  credentials_id           = databricks_mws_credentials.nonprod.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.nonprod.storage_configuration_id
  network_id               = databricks_mws_networks.nonprod.network_id

  token {
    comment = "terraform_automation"
  }
}

resource "databricks_mws_workspaces" "prod" {
  provider        = databricks.mws
  account_id      = var.databricks_account_id
  aws_region      = var.region
  workspace_name  = "prod-${local.prefix}"
  deployment_name = "prod-${local.prefix}"

  credentials_id           = databricks_mws_credentials.prod.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.prod.storage_configuration_id
  network_id               = databricks_mws_networks.prod.network_id

  token {
    comment = "terraform_automation"
  }
}