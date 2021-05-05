output "gokabot-nlb-logs" {
  value = aws_s3_bucket.gokabot-nlb-logs
}

output "gokabot-codepipeline-artifacts" {
  value = aws_s3_bucket.gokabot-codepipeline-artifacts
}
