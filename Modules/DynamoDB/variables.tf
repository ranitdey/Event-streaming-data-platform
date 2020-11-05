variable "table_name" {
    type        = string
    description = "DynamoDB table name"
}

variable "billing_mode" {
    type        = string
    description = "Billing mode for DynamoDB"
    default = "PROVISIONED"
}

variable "read_capacity" {
    type        = number
    description = "DynamoDB read capacity units"
}

variable "write_capacity" {
    type        = number
    description = "DynamoDB write capacity units"
}

variable "partition_key" {
    type        = string
    description = "DynamoDB partition key"
}

variable "sort_key" {
    type        = string
    description = "DynamoDB sort key"
    default     = ""
}

variable "attributes" {
    type = list(object({ name = string, type = string }))
}

variable "capacity" {
  type = map(number)
  description = "Max and min values for read and write"
}

variable "target_value" {
  type    = number
  description = "Target utilization threshold"
}

variable "tags" {
  description = "Tags for dynamo table"
}