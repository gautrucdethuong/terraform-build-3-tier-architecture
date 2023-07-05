terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.8.0"
    }
  }
}
provider "aws" {
  region  = "ap-southeast-1"
}

resource "aws_instance" "prod_instance" {
  ami           = "ami-0c91f4476780c2eaf"
  instance_type = "t2.micro"
}
