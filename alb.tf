resource "aws_lb" "jenkins_alb" {
  name               = "jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

resource "aws_lb_target_group" "jenkins_tg" {
  name     = "jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.jenkins_vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 60  # Health check runs every 60 seconds
    timeout             = 30  # Health check timeout increased to 30 seconds
    healthy_threshold   = 2   # Mark as healthy after 2 successful checks
    unhealthy_threshold = 5   # Mark as unhealthy after 5 failed checks
    matcher             = "200" # Expect HTTP 200 response
  }
}

resource "aws_lb_listener" "jenkins_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.jenkins_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
