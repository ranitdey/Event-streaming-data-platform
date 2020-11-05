resource "aws_dynamodb_table" "dynamodb-table" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.partition_key
  range_key      = var.sort_key

  dynamic "attribute" {
      for_each = var.attributes
      content {
          name = attribute.value.name
          type = attribute.value.type
          }
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = var.tags
}

resource "aws_appautoscaling_target" "dynamodb-table_read_target" {
    max_capacity       = var.capacity["max_read"]
    min_capacity       = var.capacity["min_read"]
    resource_id        = "table/${aws_dynamodb_table.dynamodb-table.name}"
    scalable_dimension = "dynamodb:table:ReadCapacityUnits"
    service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb-test-table_read_policy" {
    name               = "dynamodb-read-capacity-utilization-${aws_appautoscaling_target.dynamodb-table_read_target.resource_id}"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.dynamodb-table_read_target.resource_id
    scalable_dimension = aws_appautoscaling_target.dynamodb-table_read_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.dynamodb-table_read_target.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
            predefined_metric_type = "DynamoDBReadCapacityUtilization"
        }
        target_value = var.target_value
    }
}

resource "aws_appautoscaling_target" "dynamodb-table_write_target" {
    max_capacity       = var.capacity["max_write"]
    min_capacity       = var.capacity["min_write"]
    resource_id        = "table/${aws_dynamodb_table.dynamodb-table.name}"
    scalable_dimension = "dynamodb:table:WriteCapacityUnits"
    service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb-test-table_write_policy" {
    name               = "dynamodb-write-capacity-utilization-${aws_appautoscaling_target.dynamodb-table_write_target.resource_id}"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.dynamodb-table_write_target.resource_id
    scalable_dimension = aws_appautoscaling_target.dynamodb-table_write_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.dynamodb-table_write_target.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
            predefined_metric_type = "DynamoDBWriteCapacityUtilization"
        }
        target_value = var.target_value
    }
}