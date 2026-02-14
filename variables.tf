variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "The type of EC2 instance"
}

variable "ec2_count" {
  type = number
  default = 2
}

variable "key_pair" {
  type = string
  default = "dw"
}

variable "ami_version" {
  type = string
  default = "al2023-ami-*-kernel-*-x86_64"
}

####################################
# network infrastructure variables #
####################################

variable "region" {
  type = string
  default = "eu-north-1"
  description = "default region for our resources"
}

variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  type = string
  default = "true"
}

variable "sg_ingress_rules" {
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string   # "tcp", "udp", or "-1"
    cidr_ipv4   = string   # example: "0.0.0.0/0" or "1.2.3.4/32"
  }))
}

variable "private_subnets_conf" {
  type = number
  default = 2
}

variable "use_modules" {
  type        = bool
  default     = true
  description = "Set to true to deploy an additional module-based stack from main-modules.tf"
}
