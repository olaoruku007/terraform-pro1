provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "instance-pro" {
  ami           =  "ami-0a04068a95e6a1cde" 
  instance_type = "t2.medium"
  
  tags = {
    Name = "terraform-pro"
  }
}

 