provider "aws" {
  region = "us-east-2"
}

data "aws_key_pair" "Dev_KP_OH" {
  key_name           = "Dev_KP_OH"
  include_public_key = true
}

resource "aws_instance" "instance-pro" {
  ami           =  "ami-0a04068a95e6a1cde" 
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.pro-sg.id]
  key_name = data.aws_key_pair.Dev_KP_OH.key_name

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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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






























