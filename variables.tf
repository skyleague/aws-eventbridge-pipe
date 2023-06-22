//Main variables
variable "name" {
  type    = string
  default = null
}
variable "name_prefix" {
  type    = string
  default = null
}
variable "description" {
  type    = string
  default = null
}

# Source
variable "source_settings" {
  type = object({
    type = string
    arn  = string
    sqs = optional(object({
      batch_size                         = optional(number),
      maximum_batching_window_in_seconds = optional(number)
      }
    ))
    kinesis = optional(object({

      batch_size                         = optional(number)
      dead_letter_config                 = optional(object({ arn = string }))
      maximum_batching_window_in_seconds = optional(number),
      maximum_record_age_in_seconds      = optional(number),
      maximum_retry_attempts             = optional(number),
      on_partial_batch_item_failure      = optional(number),
      parallelization_factor             = optional(number),
      starting_position                  = optional(number),
      starting_position_timestamp        = optional(number),


    }))
    dynamodb = optional(object({
      batch_size                         = optional(number),
      dead_letter_config                 = optional(object({ arn = string }))
      maximum_batching_window_in_seconds = optional(number),
      maximum_record_age_in_seconds      = optional(number),
      maximum_retry_attempts             = optional(number),
      on_partial_batch_item_failure      = optional(number),
      parallelization_factor             = optional(number),
      starting_position                  = optional(number),
    }))

    filters = optional(list(object({ pattern = string })))


  })
  validation {
    condition     = var.source_settings.arn != null && contains(["sqs", "kinesis", "dynamodb"], var.source_settings.type)
    error_message = "Source of type ${var.source_settings.type} is not (yet) suported"
  }
}

# Enrichment
variable "enrichment_settings" {
  type = object({
    arn            = string
    type           = string
    input_template = optional(string)
    http = optional(object({
      header_parameters       = map(string),
      path_parameter_values   = list(string)
      query_string_parameters = map(string)
    }))
  })
  default = null
}

# Target
variable "target_settings" {
  type = object({
    arn            = string
    type           = string
    input_template = optional(string)
    eventbridge = optional(object({
      detail_type = optional(string)
      endpoint_id = optional(string)
      resources   = optional(list(string))
      source      = optional(string)
      time        = optional(string)

    }))
    lambda = optional(object({
      invocation_type = optional(string)
    }))
  })
}
