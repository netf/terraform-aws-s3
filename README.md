# terraform-aws-s3

Terraform module for AWS S3 buckets

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bucket\_acl |  | string | `"private"` | no |
| bucket\_owner\_full\_control |  | bool | `"true"` | no |
| enable\_sse |  | bool | `"false"` | no |
| enabled |  | bool | `"true"` | no |
| kms\_master\_key\_id |  | string | `""` | no |
| logging |  | list(map(string)) | `[]` | no |
| sqs\_notification |  | bool | `"false"` | no |
| tags |  | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_arn |  |
| bucket\_domain\_name |  |
| bucket\_id |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
