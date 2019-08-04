# ToDo: start using external IDs with roles for better security: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html

locals {
  bucket_id = var.enabled ? compact(concat(aws_s3_bucket.bucket_with_encryption.*.id, aws_s3_bucket.bucket_without_encryption.*.id))[0] : ""
}

resource "aws_s3_bucket" "bucket_with_encryption" {
  count = var.enabled && var.enable_sse ? 1 : 0

  bucket = var.name

  versioning {
    enabled = var.enable_versioning
  }

  acl = var.bucket_acl

  request_payer = var.request_payer

  tags = merge(var.tags, {
    "Name" = var.name
  })

  dynamic "logging" {
    for_each = [for l in var.logging: {
      target_bucket = l.target_bucket
      target_prefix = l.target_prefix
    }]
    content {
      target_bucket = logging.value.target_bucket
      target_prefix = logging.value.target_prefix
    }
  }

  lifecycle_rule {
    id      = "${var.name}-content"
    enabled = var.enable_lifecycle

    prefix = "/"

    transition {
      days          = var.standard_transition_days
      storage_class = "STANDARD_IA"                     # or "ONEZONE_IA"
    }

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }

//    expiration {
//       days = 90
//    }

  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_master_key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket" "bucket_without_encryption" {
  count = var.enabled && !var.enable_sse ? 1 : 0

  bucket = var.name

  versioning {
    enabled = var.enable_versioning
  }

  acl = var.bucket_acl

  request_payer = var.request_payer

  tags = merge(var.tags, {
    "Name" = var.name
  })

  dynamic "logging" {
    for_each = [for l in var.logging: {
      target_bucket = l.target_bucket
      target_prefix = l.target_prefix
    }]
    content {
      target_bucket = logging.value.target_bucket
      target_prefix = logging.value.target_prefix
    }
  }

  lifecycle_rule {
    id      = "${var.name}-content"
    enabled = var.enable_lifecycle

    prefix = "/"

    transition {
      days          = var.standard_transition_days
      storage_class = "STANDARD_IA"                     # or "ONEZONE_IA"
    }

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }

    # Do we ever expire data ? 
    # expiration {
    #   days = 90
    # }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.enabled && var.sqs_notification ? 1 : 0
  bucket = local.bucket_id

  queue {
    queue_arn = aws_sqs_queue.queue[0].arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# ToDo: this resource should be created by a standalone SQS module
resource "aws_sqs_queue" "queue" {
  count = var.enabled && var.sqs_notification ? 1 : 0
  name  = "${var.name}-notifications"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:${var.name}-notifications",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "arn:aws:s3:::${local.bucket_id}" }
      }
    }
  ]
}
POLICY
}

data "aws_iam_policy_document" "source_policy" {
  count = var.enabled && var.bucket_owner_full_control ? 0 : 1

  statement {
    sid = "AllowRead"

    actions = ["s3:List*", "s3:GetObject*"]

    principals {
      type        = "AWS"
      identifiers = var.allow_read
    }

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${local.bucket_id}",
      "arn:aws:s3:::${local.bucket_id}/*",
    ]
  }

  statement {
    sid = "AllowWrite"

    actions = ["s3:PutObject", "s3:PutObject*", "s3:DeleteObject*",
      "s3:DeleteObject*",
      "s3:RestoreObject",
      "s3:AbortMultipartUpload",
      "s3:List*",
      "s3:GetObject*",
    ]

    principals {
      type        = "AWS"
      identifiers = var.allow_write
    }

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${local.bucket_id}",
      "arn:aws:s3:::${local.bucket_id}/*",
    ]
  }

  statement {
    sid = "DenyIPAddr"

    actions = [
      "s3:PutObject",
      "s3:PutObject*",
      "s3:DeleteObject*",
      "s3:RestoreObject",
      "s3:AbortMultipartUpload",
      "s3:GetObject*",
    ]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    effect = "Deny"

    resources = [
      "arn:aws:s3:::${local.bucket_id}",
      "arn:aws:s3:::${local.bucket_id}/*",
    ]

    condition {
      test     = "NotIpAddress"
      values   = var.allow_ipaddr
      variable = "aws:SourceIP"
    }
  }
}

data "aws_iam_policy_document" "source_policy_bucket_owner_full_control" {
  count = var.enabled && var.bucket_owner_full_control ? 1 : 0

  statement {
    sid = "AllowRead"

    actions = ["s3:List*", "s3:GetObject*"]

    principals {
      type        = "AWS"
      identifiers = var.allow_read
    }

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${local.bucket_id}",
      "arn:aws:s3:::${local.bucket_id}/*",
    ]
  }

  statement {
    sid = "AllowWrite"

    actions = ["s3:PutObject", "s3:PutObject*", "s3:DeleteObject*",
      "s3:DeleteObject*",
      "s3:RestoreObject",
      "s3:AbortMultipartUpload",
      "s3:List*",
      "s3:GetObject*",
    ]

    principals {
      type        = "AWS"
      identifiers = var.allow_write
    }

    effect = "Allow"

    resources = [
      "arn:aws:s3:::${local.bucket_id}",
      "arn:aws:s3:::${local.bucket_id}/*",
    ]
  }

  statement {
    sid = "DenyWrite"

    actions = ["s3:PutObject", "s3:PutObject*"]

    principals {
      type        = "AWS"
      identifiers = var.allow_write
    }

    effect = "Deny"

    resources = [
      "arn:aws:s3:::${local.bucket_id}",
      "arn:aws:s3:::${local.bucket_id}/*",
    ]

    condition {
      test     = "StringNotEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
  }

  statement {
    sid = "DenyIPAddr"

    actions = [
      "s3:PutObject",
      "s3:PutObject*",
      "s3:DeleteObject*",
      "s3:RestoreObject",
      "s3:AbortMultipartUpload",
      "s3:GetObject*",
    ]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    effect = "Deny"

    resources = [
      "arn:aws:s3:::${local.bucket_id}",
      "arn:aws:s3:::${local.bucket_id}/*",
    ]

    condition {
      test     = "NotIpAddress"
      values   = var.allow_ipaddr
      variable = "aws:SourceIP"
    }
  }
}

data "aws_iam_policy_document" "policy_bucket_owner_full_control" {
  count         = var.enabled && var.bucket_owner_full_control ? 1 : 0
  source_json   = data.aws_iam_policy_document.source_policy_bucket_owner_full_control[0].json
  override_json = jsonencode(var.override_policy)
}

resource "aws_s3_bucket_policy" "policy_bucket_owner_full_control" {
  count  = var.enabled && var.bucket_owner_full_control ? 1 : 0
  bucket = local.bucket_id
  policy = data.aws_iam_policy_document.policy_bucket_owner_full_control[0].json
}

data "aws_iam_policy_document" "policy" {
  count         = var.enabled && var.bucket_owner_full_control == false ? 1 : 0
  source_json   = data.aws_iam_policy_document.source_policy[0].json
  override_json = jsonencode(var.override_policy)
}

resource "aws_s3_bucket_policy" "policy" {
  count  = var.enabled && var.bucket_owner_full_control == false ? 1 : 0
  bucket = local.bucket_id
  policy = data.aws_iam_policy_document.policy[0].json
}
