
# Launch Jenkins Agent EC2 Instance
resource "aws_instance" "jenkins_agent" {
  ami                    = "ami-05c179eced2eb9b5b"
  instance_type          = "t3.micro"
  security_groups        = [aws_security_group.jenkins_sg.id]
  subnet_id              = aws_subnet.public_subnet_2.id
  iam_instance_profile   = aws_iam_instance_profile.jenkins_agent_profile.name
  associate_public_ip_address = true

  # User Data to Install Jenkins Agent and Connect it to Jenkins Master
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y java-11-amazon-corretto
    yum install -y git

    # Install Jenkins Agent
    mkdir -p /home/ec2-user/jenkins-agent
    cd /home/ec2-user/jenkins-agent

    EOF

  tags = {
    Name = "Jenkins-Agent"
  }
}


resource "aws_iam_instance_profile" "jenkins_agent_profile" {
  name = "jenkins-agent-profile"
  role = aws_iam_role.jenkins_agent_role.name
}


# IAM Role for Jenkins Agent
resource "aws_iam_role" "jenkins_agent_role" {
  name = "jenkins-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
  role       = aws_iam_role.jenkins_agent_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "JenkinsCloudWatchLogsPolicy"
  description = "Allows Jenkins Agent to push logs to CloudWatch"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
  }
  EOF
}
