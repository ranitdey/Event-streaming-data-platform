module "consumer_lambda" {
    source = "./Modules/ConsumerLambda"
    event_source_kinesis_stream_arn                   = module.input_kinesis_stream.stream_arn
    output_stream_name                                = var.output_stream_name
    output_stream_region                              = var.region
    user_details_table_name                           = var.user_table_name
    user_subscription_table_name                      = var.user_subscription_table_name
    lambda_function_name                              = var.lambda_function_name
    lambda_handler                                    = var.lambda_handler
    memory_size                                       = var.memory_size
    runtime                                           = var.runtime
    timeout                                           = var.timeout
    tags                                              = var.tags
    lambda_event_source_consumption_starting_position = var.lambda_event_source_consumption_starting_position
    lambda_event_source_mapping_batch_size            = var.lambda_event_source_mapping_batch_size
    lambda_event_source_mapping_enabled               = var.lambda_event_source_mapping_enabled
}
module "user_subscription_dynamodb_table" {
    source = "./Modules/DynamoDB"
    table_name     = var.user_subscription_table_name
    read_capacity  = var.user_subscription_table_provisioned_capacity["read_capacity"]
    write_capacity = var.user_subscription_table_provisioned_capacity["write_capacity"]
    partition_key  = var.user_subscription_table_partition_key
    sort_key       = var.user_subscription_table_sort_key
    attributes     = var.user_subscription_table_attributes
    capacity       = var.autoscaling_capacity
    target_value   = var.table_usage_threshold
    tags           = var.tags
}

module "user_dynamodb_table" {
    source = "./Modules/DynamoDB"
    table_name     = var.user_table_name
    read_capacity  = var.user_table_provisioned_capacity["read_capacity"]
    write_capacity = var.user_table_provisioned_capacity["write_capacity"]
    partition_key  = var.user_table_partition_key
    attributes     = var.user_table_attributes
    capacity       = var.autoscaling_capacity
    target_value   = var.table_usage_threshold
    tags           = var.tags
}


module "input_kinesis_stream" {
    source           = "./Modules/KinesisDataStream"
    stream_name      = var.input_stream_name
    retention_period = var.input_stream_retention_period
    shard_count      = var.input_stream_shard_count
    tags             = var.tags
}

module "output_kinesis_stream" {
    source           = "./Modules/KinesisDataStream"
    stream_name      = var.output_stream_name
    retention_period = var.output_stream_retention_period
    shard_count      = var.output_stream_shard_count
    tags             = var.tags
}