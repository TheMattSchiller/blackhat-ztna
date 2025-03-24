locals {
  tags = {
    Name = var.tag
  }
}

variable "region" {
  default = "us-west-2"
}

variable "availability_zone_a" {
  default = "us-west-2a"
}

variable "availability_zone_b" {
  default = "us-west-2b"
}

variable "tag" {
  default = "boundary"
}

variable "vpc_subnet" {
  default = "10.1.0.0/16"
}

variable "public_subnet" {
  default = "10.1.1.0/24"
}

variable "public_subnet_b" {
  default = "10.1.2.0/24"
}

variable "private_subnet" {
  default = "10.1.0.0/24"
}
