terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-pro1-s3-bkt"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-pro1-locks"
    encrypt        = true
  }
}



data "aws_key_pair" "Dev_KP" {
  key_name           = var.key_pair_name
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

data "aws_security_group" "default_vpc_sg" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name = "group-name"
    values = ["default"]
  }
}

resource "aws_launch_configuration" "instance-lc-asg" {
  image_id                    = var.image_id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.pro-sg.id]
  key_name                    = data.aws_key_pair.Dev_KP.key_name
  #associate_public_ip_address = true
  user_data                   = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install httpd -y
              systemctl enable httpd
              systemctl start httpd
              EC2AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
              echo '<center><h1>Hello, World! This is Wakandom Lomo. This Amazon EC2 instance is located in Availability Zone: AZID </h1></center>' > /var/www/html/index.txt
              sed "s/AZID/$EC2AZ/" /var/www/html/index.txt > /var/www/html/index.html
              systemctl restart httpd
              
              EOF

  # Required when using a launch configuration with an ASG.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "pro-asg" {
  launch_configuration = aws_launch_configuration.instance-lc-asg.name

  min_size = 5
  max_size = 5

  vpc_zone_identifier =  data.aws_subnets.default.ids
               
  
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  # depends_on = [
  #   aws_lb.terraform-alb
  # ]

  tag {
    key                 = "Name"
    value               = "terraform-pro-asg"
    propagate_at_launch = true
  }
}


resource "aws_security_group" "pro-sg" {
  name   = "terraform-pro-sg"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port   = var.HTTP_port
    to_port     = var.HTTP_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
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
  subnets            =  data.aws_subnets.default.ids
    

  security_groups    = [aws_security_group.alb.id, data.aws_security_group.default_vpc_sg.id]
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
    from_port   = var.HTTP_port
    to_port     = var.HTTP_port
    protocol    = "tcp"
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
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
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

output "instance_ips" {
  value =  aws_launch_configuration.instance-lc-asg.*.associate_public_ip_address
    
  description = "The public IP addresses of the web server"
}