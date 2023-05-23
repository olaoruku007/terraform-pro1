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
    type = string
    default = "us-east-1"
  
}