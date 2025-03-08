resource "aws_cloudwatch_log_group" "jenkins_logs" {
  name = "/ecs/jenkins"
  retention_in_days = 7
}

resource "aws_iam_policy" "ecs_task_logging" {
  name        = "ecsTaskLogging"
  description = "Allows ECS tasks to write logs to CloudWatch"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:ap-south-1:600627350364:log-group:/ecs/jenkins:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_logging_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_logging.arn
}
