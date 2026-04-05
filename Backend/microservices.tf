resource "aws_sqs_queue" "report_queue" {
    name = "report_generation"
    delay_seconds = 0
    max_message_size = 262144
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
}

resource "aws_sns_topic" "report_alert" {
  name = "budget_report_alert"
}

resource "aws_s3_bucket" "report_Storage" {
  bucket = "budget-tracker-reports-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "budget_lambda_exec_role"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }]
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_log" {
  role = aws_iam_role.lambda_exec_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_permission" {
  name = "budget_lambda_permission"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    version = "2012-10-17"
    Statment = [{
      Effect = "Allow"
      Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      Resource = aws_sqs_queue.report_queue.arn
    },
    {
      Effect = "Allow"
      Action = ["s3:PutObject"]
      Resource = "${aws_s3_bucket.report_Storage.arn}/*"
    },
    {
      Effect = "Allow"
      Action = ["sns:Publish"]
      Resource = aws_sns_topic.report_alert.arn
    }
    ]
  })
}

data "archive_file" "dummy_lambda" {
  type = "zip"
  output_path = "lambda_function.zip"
  source {
    content = "def lambda_handler(event, context):\n print('Report Generated!)\n return 'Success'"
    filename = "index.py"
  }
}

resource "aws_lambda_function" "report_generator" {
  function_name = "budget_report_generation"
  role = aws_iam_role.lambda_exec_role.arn
  handler = "index.lamda_handler"
  runtime = "python3.9"

  filename = data.archive_file.dummy_lambda.output_path
  source_code_hash = data.archive_file.dummy_lambda.output_base64sha256

  environment {
    variables = {
      REPORT_BUCKET = aws_s3_bucket.report_Storage.bucket
      SNS_TOPIC_ARN = aws_sns_topic.report_alert.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.report_queue.arn
  function_name = aws_lambda_function.report_generator.arn
  batch_size = 1
}