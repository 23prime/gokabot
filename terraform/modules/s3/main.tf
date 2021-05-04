resource "aws_s3_bucket" "gokabot-nlb-logs" {
  bucket = "gokabot-nlb-logs"

  tags = {
    Name = "gokabot-nlb-logs"
    cost = var.cost_tag
  }
}

resource "aws_s3_bucket_policy" "gokabot-nlb-logs-policy" {
  bucket = aws_s3_bucket.gokabot-nlb-logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "GokabotNLBLogsPolicy"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl"
        ]
        Resource = [
          aws_s3_bucket.gokabot-nlb-logs.arn,
          "${aws_s3_bucket.gokabot-nlb-logs.arn}/*",
        ]
      }
    ]
  })
}
