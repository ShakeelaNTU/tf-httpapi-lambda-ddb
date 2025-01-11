# Use a data source to reference the existing Lambda function
data "aws_lambda_function" "http_api_lambda" {
  function_name = "shakee-topmovies-api" # Replace with the actual Lambda function name
}

# Create an SNS topic for notifications
resource "aws_sns_topic" "lambda_alarm_notification" {
  name = "lambda-error-alarm-topic"
}

# Create an SNS topic subscription (email notification)
resource "aws_sns_topic_subscription" "lambda_alarm_subscription" {
  topic_arn = aws_sns_topic.lambda_alarm_notification.arn
  protocol  = "email"
  endpoint  = "shilu2u@gmail.com" # Replace with your email address
}

# Create a CloudWatch Alarm for Lambda errors
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "LambdaErrorAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "This alarm triggers if the Lambda function has 1 or more errors in a 1-minute period."

  # Use the Lambda function's name from the data source
  dimensions = {
    FunctionName = data.aws_lambda_function.http_api_lambda.function_name
  }

  # SNS Topic for notifications
  alarm_actions = [aws_sns_topic.lambda_alarm_notification.arn]
}
