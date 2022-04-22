resource "aws_s3_bucket" "nonprod_root_bucket" {
  bucket = "nonprod-${local.prefix}"
  force_destroy = true
  tags = merge(var.tags, {
    Name = "nonprod-${local.prefix}"
    Environment = "nonprod"
  })
}

resource "aws_s3_bucket" "prod_root_bucket" {
  bucket = "prod-${local.prefix}"
  force_destroy = true
  tags = merge(var.tags, {
    Name =  "prod-${local.prefix}"
    Environment = "prod"
  })
}

resource "aws_s3_bucket_versioning" "nonprod_root_bucket" {
  bucket = aws_s3_bucket.nonprod_root_bucket.id
  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_versioning" "prod_root_bucket" {
  bucket = aws_s3_bucket.prod_root_bucket.id
  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "nonprod_root_bucket" {
  bucket               = aws_s3_bucket.nonprod_root_bucket.id
  block_public_acls    = true
  block_public_policy  = true
  ignore_public_acls   = true
  restrict_public_buckets = true
  depends_on         = [aws_s3_bucket.nonprod_root_bucket]
}

resource "aws_s3_bucket_public_access_block" "prod_root_bucket" {
  bucket              =  aws_s3_bucket.prod_root_bucket.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
  depends_on         = [aws_s3_bucket.prod_root_bucket]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "nonprod_root_bucket" {
  bucket = aws_s3_bucket.nonprod_root_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prod_root_bucket" {
  bucket = aws_s3_bucket.prod_root_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

data "databricks_aws_bucket_policy" "nonprod_bucket_policy" {
  bucket = aws_s3_bucket.nonprod_root_bucket.bucket
}

resource "aws_s3_bucket_policy" "nonprod_bucket_policy" {
  bucket     = aws_s3_bucket.nonprod_root_bucket.id
  policy     = data.databricks_aws_bucket_policy.nonprod_bucket_policy.json
  depends_on = [aws_s3_bucket_public_access_block.nonprod_root_bucket]
}

data "databricks_aws_bucket_policy" "prod_bucket_policy" {
  bucket = aws_s3_bucket.prod_root_bucket.bucket
}

resource "aws_s3_bucket_policy" "prod_bucket_policy" {
  bucket     = aws_s3_bucket.prod_root_bucket.id
  policy     = data.databricks_aws_bucket_policy.prod_bucket_policy.json
  depends_on = [aws_s3_bucket_public_access_block.prod_root_bucket]
}