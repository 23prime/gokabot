output "GokabotTaskExecutionRole" {
  value = aws_iam_role.GokabotTaskExecutionRole
}

output "GokabotCodeBuildServiceRole" {
  value = aws_iam_role.GokabotCodeBuildServiceRole
}

output "GokabotCodeDeployServiceRole" {
  value = aws_iam_role.GokabotCodeDeployServiceRole
}

output "GokabotCodePipelineServiceRole" {
  value = aws_iam_role.GokabotCodePipelineServiceRole
}

output "GokabotEventTargetRole" {
  value = aws_iam_role.GokabotEventTargetRole
}
