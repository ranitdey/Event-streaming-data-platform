variable "event_source_kinesis_stream_arn" {
  type        = string
  description = "Source Kinesis Data Streams stream name"
}

variable "output_stream_region" {
  description = "Region of output stream where all the events will be passed"
}
variable "output_stream_name" {
  description = "Name of output stream where all the events will be passed"
}
variable "user_details_table_name" {
  description = "Table name where user details are present"
}
variable "user_subscription_table_name" {
  description = "Table name where user subscription state is stored"
}
variable "lambda_function_name" {
  description = "Name of the lambda function"
}

variable "lambda_handler" {
  description = "Handler for lambda function"
}

variable "memory_size" {
  description = "Memory size of the lambda function"
}

variable "timeout" {
  description = "Timeout limit the lambda function"
}

variable "runtime" {
  description = "Runtime environment for lambda"
}

variable "tags" {
  description = "Tags for lambda function"
}

variable "lambda_event_source_mapping_batch_size" {
  description = "Batch read size for lambda event source mapping to kinesis"
}

variable "lambda_event_source_mapping_enabled" {
  description = "Flag to enable lambda event source mapping"
}

variable "lambda_event_source_consumption_starting_position" {
  description = "Position from where the event consumption will happen"
}