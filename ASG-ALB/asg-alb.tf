data "aws_key_pair" "Dev_KP_OH" {
  key_name           = "Dev_KP_OH"
  include_public_key = true
}

data "aws_vpc" "default" {
  id = "vpc-0f9295df75cd034c7"
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
  user_data       = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install figlet -y
              dnf install httpd -y
              systemctl enable httpd
              systemctl start httpd
              echo "Hello World! This is Wakandom Lomo." > /var/www/html/index.html
              systemctl restart httpd
              
              EOF

  # Required when using a launch configuration with an ASG.
  lifecycle {
    create_before_destroy = true
  }


}

resource "aws_autoscaling_group" "pro-asg" {
  launch_configuration = aws_launch_configuration.instance-lc-asg.name
  vpc_zone_identifier  = data.aws_subnets.default.ids
  min_size             = 2
  max_size             = 2

  tag {
    key                 = "Name"
    value               = "terraform-pro-asg"
    propagate_at_launch = true
  }
}




resource "aws_security_group" "pro-sg" {
  name = "terraform-pro1-sg"
  vpc_id      = data.aws_vpc.default.id
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
































