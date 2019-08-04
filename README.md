# terraform-aws-s3

Terraform module for AWS S3 buckets

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allow\_ipaddr |  | list | `[ "0.0.0.0/0" ]` | no |
| allow\_read |  | list | `[]` | no |
| allow\_write |  | list | `[]` | no |
| bucket\_acl | https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl | string | `"private"` | no |
| bucket\_owner\_full\_control |  | string | `"true"` | no |
| enable\_lifecycle |  | string | `"true"` | no |
| enable\_sse |  | string | `"false"` | no |
| enable\_versioning |  | string | `"false"` | no |
| glacier\_transition\_days |  | string | `"60"` | no |
| kms\_master\_key\_id |  | string | `""` | no |
| logging |  | list | `[]` | no |
| name |  | string | n/a | yes |
| override\_policy |  | map | `{}` | no |
| request\_payer |  | string | `"BucketOwner"` | no |
| sqs\_notification |  | string | `"false"` | no |
| standard\_transition\_days |  | string | `"30"` | no |
| tags |  | map | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_arn |  |
| bucket\_domain\_name |  |
| bucket\_id |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
