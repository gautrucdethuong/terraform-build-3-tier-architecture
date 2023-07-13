# AWS EC2 Instance Type
variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.micro"
}
# AWS EC2 Instance Key Pair
variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type        = string
  default     = "terraform"
}

# AWS EC2 Instance Count
variable "private_instance_count" {
  description = "Number EC2 Instance create"
  type        = number
  default     = 2
}