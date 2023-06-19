# Currently, We are utilizing the  AWS Cloud Control  (awscc)  version of the resouces 
# because the stable version (aws) does not allow for the use of parameters.
# However, to expedite the implementation of parameter support,
# We encourage you to contribute by voting on this pull request (PR). 
# By doing so, we can facilitate its inclusion in the stable version of aws sooner.
# https://github.com/hashicorp/terraform-provider-aws/pull/31607#issue-1728257255


resource "awscc_pipes_pipe" "this" {
  name = var.name != null ? var.name : "${var.name_prefix}-${random_uuid.suffix.result}"

  role_arn = aws_iam_role.this.arn

  source = var.source_settings.arn

  # source_parameters = try(var.source_settings.parameters, null)
  source_parameters = {
    sqs_queue_parameters        = var.source_settings.sqs,
    kinesis_stream_parameters   = var.source_settings.kinesis,
    dynamo_db_stream_parameters = var.source_settings.dynamodb,
    filter_criteria             = { filters = var.source_settings.filters }
  }

  enrichment = try(var.enrichment_settings.arn, null)
  enrichment_parameters = {
    input_template  = var.enrichment_settings.input_template
    http_parameters = var.enrichment_settings.http_parameters
  }

  target = var.target_settings.arn
  target_parameters = {
    input_template                    = var.target_settings.input_template
    event_bridge_event_bus_parameters = var.target_settings.eventbridge
    lambda_function_parameters        = var.target_settings.lambda
  }
  lifecycle {
    precondition {
      condition     = var.name != null || var.name_prefix != null
      error_message = "Either name or name_prefix must be provided"
    }
    precondition {
      condition     = var.name == null || var.name_prefix == null
      error_message = "Either name or name_prefix must be provided, not both"
    }
    replace_triggered_by = [null_resource.re_trigger_pipe]
  }
}

resource "null_resource" "re_trigger_pipe" {
  triggers = {
    source     = coalesce(jsonencode(try(var.source_settings, null)), "")
    target     = coalesce(jsonencode(try(var.target_settings, null)), "")
    enrichment = coalesce(jsonencode(try(var.enrichment_settings, null)), "")
  }
}
resource "random_uuid" "suffix" {
}
