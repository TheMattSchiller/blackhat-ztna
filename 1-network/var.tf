locals {
  tags = {
    Name = var.tag
  }
}

variable "tag" {
  default = "boundary"
}

variable "public_subnet" {
  default = ""
}

variable "public_subnet_b" {
  default = ""
}

variable "private_subnet" {
  default = ""
}

variable "availability_zone" {
  default = ""
}