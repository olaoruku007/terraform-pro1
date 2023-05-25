terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "terraform-pro1-s3-bkt"
    key    = "vpc/s3/terraform.tfstate"
    region = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-pro1-locks"
    encrypt        = true
  }

}