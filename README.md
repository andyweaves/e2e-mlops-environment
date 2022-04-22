# e2e-mlops-environment
Demo repository which creates an environment to run the end-to-end MLOps workflow defined in https://github.com/niall-turbitt/e2e-mlops on Databricks.

### Setup

1. [Download and Install Terraform](https://www.terraform.io/downloads)
2. [Download, Install and Configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. Open [variables.tf](variables.tf) and customise or prepare the input variables as per your environment. At a minimum you'll need:
    * A Databricks account id, username and password
    * An IAM Role ARN to be used as the Databricks cross account role (optional as to whether a different role is used for non prod and prod)
4. Run ```terraform init```
5. Run ```terraform apply```

Once ```terraform apply``` has been run successfully, the output will contain:

1. databricks_nonprod_url = The URL for your nonprod Databricks workspace
2. databricks_prod_url = The URL for your prod Databricks workspace
3. resource_prefix = a prefix that is added to all AWS and Databricks resources as follows: ```nonprod|prod```-```resource_prefix```
