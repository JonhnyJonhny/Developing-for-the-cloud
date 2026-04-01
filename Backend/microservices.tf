resource "aws_sqs_queue" "report_queue" {
    name = "report_generation"
    delay_seconds = 0
    max_message_size = 262144
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
}

resource "aws_s3_bucket" "report_Storage" {
  bucket = "budget-tracker-reports-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}