variable "aws_region" {
    type = string
    default = "ap-south-1"
  
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
  
}


variable "public_subnet" {
    type = string
    default = "10.0.1.0/24"
  
}

variable "private_subnet" {
    type = string
    default = "10.0.2.0/24"
  
}

variable "env" {
    type = string
    default = "Dev"
  
}

