variable "region" {
  description = "The region the resources will be launched"
  type        = string
  default     = "us-east-1"
}

variable "image_id" {
  description = " The ami to be used by the instance"
  type        = string
  default     = "ami-02978b79564e08f2f"
}

variable "instance_type" {
  description = " The instance type to be used"
  type        = string
  default     = "t2.small"
}

variable "HTTP_port" {
  description = " The port the server will use for http request"
  type        = number
  default     = 80
}

variable "SSH_port" {
  description = " The port the server will use for SSH_port request"
  type        = number
  default     = 22
}

variable "ALL_port" {
  description = " The port the server will use for ALL_port request"
  type        = number
  default     = 0
}

variable "id" {
  description = " The vpc_id to be used by the instance"
  type        = string
  default     = "vpc-0e1d3ed0fa157e81a"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "Dev_KP"
}
