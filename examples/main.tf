provider "aws" {
  region = "eu-west-1"
}

# Example S3 Bucket
module "s3_bucket" {
  source      = "../"
  name        = "dp-datalake-test-bucket-31337"
  enabled     = true
  allow_read  = ["arn:aws:iam::047625233815:user/netf", "arn:aws:iam::047625233815:user/ursuad"]
  allow_write = ["arn:aws:iam::047625233815:user/ursuad"]

  //  logging = [{
  //    target_bucket = "dp-datalake-dev-test-bucket-1"
  //    target_prefix = "test"
  //  }]

  sqs_notification = "true"

  tags = {
    Platform    = "DP"
    Project     = "test"
    Owner       = "test"
    Environment = "datalake"
    Importance  = "low"
  }

  enable_versioning = "true"

  //  override_policy = {
  //    Version = "2012-10-17"
  //    Id      = "123"
  //
  //    Statement = [
  //      {
  //        Sid       = "RequireMFA"
  //        Effect    = "Deny"
  //        Principal = "*"
  //        Action    = "s3:*"
  //        Resource  = "arn:aws:s3:::dp-datalake-test-bucket-31337/*"
  //
  //        Condition = {
  //          BoolIfExists = {
  //            "aws:MultiFactorAuthPresent" = "false"
  //          }
  //        }
  //      },
  //    ]
  //  }

  bucket_owner_full_control = "false"
}

# Encrypted bucket
module "bucket_key" {
  source = "git@github.com:ConnectedHomes/dp-terraform-kms.git?ref=v0.1.0"

  keys = [
    {
      description = "bucket-key-31337"
      alias       = "test-bucket-key-31337"
    },
  ]
}

resource "aws_kms_grant" "bucket_key" {
  name              = "access-bucket-31337-key"
  key_id            = module.bucket_key.key_id[0]
  grantee_principal = "arn:aws:iam::047625233815:user/ursuad"
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
}

module "encrypted_s3_bucket" {
  source                    = "../"
  name                      = "dp-datalake-test-bucket-31338"
  allow_read                = ["arn:aws:iam::047625233815:user/netf", "arn:aws:iam::047625233815:user/ursuad"]
  allow_write               = ["arn:aws:iam::047625233815:user/ursuad"]
  enable_sse                = "true"
  bucket_owner_full_control = "false"
  kms_master_key_id         = module.bucket_key.key_id[0]
}

module "encrypted_s3_bucket_owner_full_control" {
  source                    = "../"
  name                      = "dp-datalake-test-bucket-31339"
  allow_read                = ["arn:aws:iam::047625233815:user/netf", "arn:aws:iam::047625233815:user/ursuad"]
  allow_write               = ["arn:aws:iam::047625233815:user/ursuad"]
  enable_sse                = "true"
  bucket_owner_full_control = "true"
  kms_master_key_id         = module.bucket_key.key_id[0]

  allow_ipaddr = [
    "91.202.126.72/32",
  ]
}
