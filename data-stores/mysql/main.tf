resource "aws_db_instance" "pro1-db" {
  identifier_prefix   = "terraform-pro1-db"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true
  db_name             = "terraform_pro1_db"
  publicly_accessible = false
  # How should we set the username and password?
  username = var.master_username
  password = var.master_password
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-pro1-s3-bkt"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-pro1-locks"
    encrypt        = true
  }
}
