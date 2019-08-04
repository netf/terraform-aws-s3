output "bucket_arn" {
  value = concat(aws_s3_bucket.bucket_with_encryption.*.arn, aws_s3_bucket.bucket_without_encryption.*.arn, list(""))[0]
}

output "bucket_id" {
  value = concat(aws_s3_bucket.bucket_with_encryption.*.id, aws_s3_bucket.bucket_without_encryption.*.id, list(""))[0]
}

output "bucket_domain_name" {
  value = concat(aws_s3_bucket.bucket_with_encryption.*.bucket_domain_name, aws_s3_bucket.bucket_without_encryption.*.bucket_domain_name, list(""))[0]
}
