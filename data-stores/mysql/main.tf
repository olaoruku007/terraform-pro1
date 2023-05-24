data "aws_vpc" "default" {
  id = var.id
}
resource "aws_subnet" "terraform-pro" {
  vpc_id     = data.aws_vpc.default.id
  cidr_block = "10.1.32.0/20"
  availability_zone = "us-east-1c" 
  map_public_ip_on_launch = false  
  
    tags = {
    Name = "Test-vpc-Private-subnet1"
  }
}

resource "aws_subnet" "terraform-pro1" {
  vpc_id     = data.aws_vpc.default.id
  cidr_block = "10.1.48.0/20"
  availability_zone = "us-east-1d" 
  map_public_ip_on_launch = false
  
    tags = {
    Name = "Test-vpc-Private-subnet2"
  }
}

resource "aws_db_subnet_group" "db-subnet" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.terraform-pro.id, aws_subnet.terraform-pro1.id]

}

resource "aws_db_instance" "pro1-db" {
  identifier_prefix    = "terraform-pro1-db"
  engine               = "mysql"
  allocated_storage    = 10
  instance_class       = "db.t2.micro"
  skip_final_snapshot  = true
  db_name              = "terraform_pro1_db"
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.db-subnet.name

  # How should we set the username and password?
  username = var.master_username
  password = var.master_password
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "terraform-pro1-s3-bkt"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-pro1-locks"
    encrypt        = true
  }
}
