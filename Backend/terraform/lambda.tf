# ============================================================
#  lambda.tf — Report generation pipeline
#  S3 (output) → SQS (queue) → Lambda (processor) → SNS (email)
# ============================================================

# ── S3 bucket — stores generated reports ─────────────────────
resource "aws_s3_bucket" "reports" {
  bucket = "budget-tracker-reports-${data.aws_caller_identity.current.account_id}"
  tags   = { Name = "budget-tracker-reports" }
}

resource "aws_s3_bucket_lifecycle_configuration" "reports" {
  bucket = aws_s3_bucket.reports.id
  rule {
    id     = "expire-old-reports"
    status = "Enabled"
    filter { prefix = "reports/" }
    expiration { days = 90 }
  }
}

resource "aws_s3_bucket_public_access_block" "reports" {
  bucket                  = aws_s3_bucket.reports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── SNS topic — sends email when report is ready ─────────────
resource "aws_sns_topic" "report_ready" {
  name = "budget-report-ready"
}

resource "aws_sns_topic_subscription" "report_email" {
  topic_arn = aws_sns_topic.report_ready.arn
  protocol  = "email"
  endpoint  = var.report_email
}

# ── SQS queue — decouples API from Lambda ────────────────────
resource "aws_sqs_queue" "report_jobs" {
  name                       = "budget-report-jobs"
  visibility_timeout_seconds = 300   # must be >= Lambda timeout
  message_retention_seconds  = 3600
  receive_wait_time_seconds  = 20    # long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.report_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue" "report_dlq" {
  name                      = "budget-report-jobs-dlq"
  message_retention_seconds = 86400
}

# ── Lambda IAM role ───────────────────────────────────────────
resource "aws_iam_role" "lambda_report" {
  name = "lambda-report-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_report_policy" {
  name = "lambda-report-policy"
  role = aws_iam_role.lambda_report.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.report_jobs.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject"]
        Resource = "${aws_s3_bucket.reports.arn}/reports/*"
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.report_ready.arn
      },
      {
        # Allow Lambda to connect to RDS inside VPC
        Effect   = "Allow"
        Action   = ["ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
        Resource = "*"
      }
    ]
  })
}

# ── Lambda function ───────────────────────────────────────────
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../Lambda"
  output_path = "${path.module}/lambda_report.zip"
}

resource "aws_lambda_function" "report_generator" {
  function_name    = "budget-report-generator"
  role             = aws_iam_role.lambda_report.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60
  memory_size      = 256

  vpc_config {
    subnet_ids         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      S3_BUCKET     = aws_s3_bucket.reports.bucket
      SNS_TOPIC_ARN = aws_sns_topic.report_ready.arn
      DB_HOST       = aws_db_instance.mysql.address
      DB_PORT       = "3306"
      DB_NAME       = "appdb"
      DB_USER       = var.db_username
      DB_PASSWORD   = var.db_password
    }
  }
}

# ── VPC Endpoints so Lambda (private subnet) can reach AWS services ──
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private1.id, aws_route_table.private2.id]
  tags = { Name = "s3-endpoint" }
}

resource "aws_vpc_endpoint" "sns" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.sns"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids  = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true
  tags = { Name = "sns-endpoint" }
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids  = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true
  tags = { Name = "sqs-endpoint" }
}

# ── SQS triggers Lambda ───────────────────────────────────────
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.report_jobs.arn
  function_name    = aws_lambda_function.report_generator.arn
  batch_size       = 1
}

# ── Security group for Lambda (needs RDS access) ─────────────
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-report-sg"
  description = "Allow Lambda to reach RDS and internet"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow Lambda SG to reach RDS
resource "aws_security_group_rule" "rds_from_lambda" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
}

# ── Data source for account ID ────────────────────────────────
data "aws_caller_identity" "current" {}

# ── Outputs ───────────────────────────────────────────────────
output "sqs_queue_url" {
  description = "SQS queue URL — set this as SQS_QUEUE_URL secret in GitHub"
  value       = aws_sqs_queue.report_jobs.url
}

output "reports_bucket" {
  description = "S3 bucket storing generated reports"
  value       = aws_s3_bucket.reports.bucket
}
