variable "access_key" {
  type        = string
  description = "AWS access key"

}

variable "secret_key" {
  type        = string
  description = "AWS secret access key"

}

variable "region" {
  type        = string
  description = "AWS region to host the environment"
}

variable "user_table_name" {
  type        = string
  default     = "user"
}

variable "user_subscription_table_name" {
  type        = string
  default     = "user_subscription"
}


variable "user_subscription_table_attributes" {
    type     = list(object({ name = string, type = string }))
    default  = [{name = "user_uuid",type = "S"},
                {name = "language",type = "S"}
                ]
}

variable "user_subscription_table_partition_key" {
    type     = string
    default  = "user_uuid"
}

variable "user_subscription_table_sort_key" {
    type     = string
    default  = "language"
}

variable "user_subscription_table_provisioned_capacity" {
    type = map(number)
    default = {
    read_capacity  = 5
    write_capacity  = 5
  }
}

variable "user_table_attributes" {
    type     = list(object({ name = string, type = string }))
    default  = [{name = "uuid",type = "S"}
               ]
}

variable "user_table_partition_key" {
    type     = string
    default  = "uuid"
}

variable "user_table_provisioned_capacity" {
    type = map(number)
    default = {
    read_capacity  = 300
    write_capacity  = 50
  }
}

variable "autoscaling_capacity" {
  type = map(number)
  description = "Max and min values for read and write"
  default = {
    min_read  = 200
    max_read  = 1000
    min_write = 25
    max_write = 125
  }
}

variable "table_usage_threshold" {
  type    = number
  default = 70
  description = "Target utilization threshold"
}

variable "input_stream_name" {
    type        = string
    default     = "input"
    description = "Name of the input kinesis stream"
}

variable "input_stream_retention_period" {
    type        = number
    default     = 24
    description = "Data retention period for stream"
}

variable "input_stream_shard_count" {
    type        = number
    default     = 1
    description = "Shard count for stream"
}

variable "output_stream_name" {
    type        = string
    default     = "output"
    description = "Name of the output kinesis stream"
}

variable "output_stream_retention_period" {
    type        = number
    default     = 24
    description = "Data retention period for output stream"
}

variable "output_stream_shard_count" {
    type        = number
    default     = 1
    description = "Shard count for output stream"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the lambda function"
  default     = "consumer_lambda"
}

variable "lambda_handler" {
  type        = string
  description = "Handler for lambda function"
  default     = "lambda_handler.consume_event"
}

variable "memory_size" {
  type        = number
  description = "Memory size of the lambda function"
  default     = 128
}

variable "timeout" {
  type        = number
  description = "Timeout limit the lambda function"
  default     = 500
}

variable "runtime" {
  type        = string
  description = "Runtime environment for lambda"
  default     = "python3.8"
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {
    owner = "Data-Platform"
  }
}

variable "lambda_event_source_mapping_batch_size" {
  type        = number
  description = "Batch read size for lambda event source mapping to kinesis"
  default     = 100
}

variable "lambda_event_source_mapping_enabled" {
  type        = bool
  description = "Flag to enable lambda event source mapping"
  default     = true
}

variable "lambda_event_source_consumption_starting_position" {
  type        = string
  description = "Position from where the event consumption will happen"
  default     = "LATEST"
}