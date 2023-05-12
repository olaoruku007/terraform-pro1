data "aws_key_pair" "Dev_KP_OH" {
  key_name           = "Dev_KP_OH"
  include_public_key = true
}

data "aws_vpc" "default" {
  id = var.id
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_launch_configuration" "instance-lc-asg" {
  image_id        = var.image_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.pro-sg.id]
  key_name        = data.aws_key_pair.Dev_KP_OH.key_name


  # Required when using a launch configuration with an ASG.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "pro-asg" {
  launch_configuration = aws_launch_configuration.instance-lc-asg.name
  min_size             = 3
  max_size             = 3

  vpc_zone_identifier = [
    data.aws_subnets.default.ids[0],
    data.aws_subnets.default.ids[1],
    data.aws_subnets.default.ids[2]

  ]
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  depends_on = [
    "aws_lb.terraform-alb"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "terraform-pro-asg"
    propagate_at_launch = true
  }
}


resource "aws_security_group" "pro-sg" {
  name   = "terraform-pro1-sg"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port   = var.HTTP_port
    to_port     = var.HTTP_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.SSH_port
    to_port     = var.SSH_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = var.ALL_port
    to_port     = var.ALL_port
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "terraform-alb" {
  name               = "terraform-pro-asg-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.terraform-alb.arn
  port              = var.HTTP_port
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name   = "terraform-sg-alb"
  vpc_id = data.aws_vpc.default.id
  # Allow inbound HTTP requests
  ingress {
    from_port   = var.HTTP_port
    to_port     = var.HTTP_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = var.ALL_port
    to_port     = var.ALL_port
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-tg"
  port     = var.HTTP_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 120
    timeout             = 60
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

output "alb_dns_name" {
  value       = aws_lb.terraform-alb.dns_name
  description = "The domain name of the load balancer"
}





















