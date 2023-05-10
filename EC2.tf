data "aws_key_pair" "Dev_KP_OH" {
  key_name           = "Dev_KP_OH"
  include_public_key = true
}

resource "aws_instance" "instance-pro" {
  ami                    = var.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.pro-sg.id]
  key_name               = data.aws_key_pair.Dev_KP_OH.key_name

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install figlet -y
              dnf install httpd -y
              systemctl enable httpd
              systemctl start httpd
              echo "Hello World! This is Wakandom Lomo." > /var/www/html/index.html
              systemctl restart httpd
              
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "terraform-pro"
  }
}

resource "aws_security_group" "pro-sg" {
  name = "terraform-pro-sg"
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

output "public_ip" {
  value       = aws_instance.instance-pro.public_ip
  description = "The public IP address of the web server"
}






























