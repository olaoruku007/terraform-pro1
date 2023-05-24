variable "master_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
}

variable "master_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "This the region of the database"
  type        = string
  default     = "us-east-1"

}

variable "id" {
  description = " The vpc_id to be used by the instance"
  type        = string
  default     = "vpc-0e1d3ed0fa157e81a"
}