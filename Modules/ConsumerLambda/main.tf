locals{
    lambda_zip_location = "./output/package.zip"
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id
  policy = file("${path.module}/iam-files/lambda-policy.json")
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = file("${path.module}/iam-files/lambda-assume-policy.json")
}

resource "aws_lambda_function" "consumer_lambda" {
  filename                    = local.lambda_zip_location
  function_name               = var.lambda_function_name
  role                        = aws_iam_role.lambda_role.arn
  handler                     = var.lambda_handler
  memory_size                 = var.memory_size
  timeout                     = var.timeout

  environment {
    variables = {
      region                  = var.output_stream_region
      output_stream_name      = var.output_stream_name
      user_table_name         = var.user_details_table_name
      subscription_table_name = var.user_subscription_table_name
    }
  }
  tags                        = var.tags
  runtime                     = var.runtime

}

resource "aws_lambda_event_source_mapping" "kinesis_mapping" {
  batch_size        = var.lambda_event_source_mapping_batch_size
  event_source_arn  = var.event_source_kinesis_stream_arn
  enabled           = var.lambda_event_source_mapping_enabled
  function_name     = aws_lambda_function.consumer_lambda.arn
  starting_position = var.lambda_event_source_consumption_starting_position
}