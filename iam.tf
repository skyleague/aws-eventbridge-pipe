data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["pipes.amazonaws.com"]
    }
  }
}



data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = var.enrichment_settings.type == "lambda" ? [true] : []
    content {
      sid       = "AllowPipeToInvokeEnrichmentLambdaFunction"
      effect    = "Allow"
      actions   = ["lambda:InvokeFunction"]
      resources = [var.enrichment_settings.arn]
    }
  }
  dynamic "statement" {
    for_each = var.target_settings.type == "lambda" ? [true] : []
    content {
      sid       = "AllowPipeToInvokeTargetLambdaFunction"
      effect    = "Allow"
      actions   = ["lambda:InvokeFunction"]
      resources = [var.target_settings.arn]
    }
  }
  dynamic "statement" {
    for_each = var.enrichment_settings.type == "eventbridge" ? [true] : []
    content {
      sid       = "AllowPipeToPutTargetEvents"
      effect    = "Allow"
      actions   = ["events:PutEvents"]
      resources = [var.target_settings.arn]
    }
  }
  dynamic "statement" {
    for_each = var.source_settings.type == "sqs" ? [true] : []
    content {
      sid    = "AllowPipeToAccessSQS"
      effect = "Allow"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility"
      ]
      resources = [var.source_settings.arn]
    }
  }
  dynamic "statement" {
    for_each = var.source_settings.type == "dynamodb" ? [true] : []
    content {
      sid    = "AllowPipeToAccessDynamodb"
      effect = "Allow"
      actions = [
        "dynamodb:DescribeStream",
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:ListStreams"
      ]
      resources = [var.source_settings.arn]
    }
  }
  dynamic "statement" {
    for_each = var.source_settings.type == "kinesis" ? [true] : []
    content {
      sid    = "AllowPipeToAccessKinesisStream"
      effect = "Allow"
      actions = [
        "kinesis:DescribeStream",
        "kinesis:DescribeStreamSummary",
        "kinesis:GetRecords",
        "kinesis:GetShardIterator",
        "kinesis:ListShards",
        "kinesis:ListStreams",
        "kinesis:SubscribeToShard"
      ]
      resources = [var.source_settings.arn]
    }
  }

}
resource "aws_iam_role" "this" {
  path        = "/pipe/"
  name_prefix = coalesce(var.name, var.name_prefix)

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
resource "aws_iam_role_policy" "this" {
  role        = aws_iam_role.this.id
  name_prefix = "base"
  policy      = data.aws_iam_policy_document.this.json
}

