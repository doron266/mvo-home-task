variable "instance_type" {
  type        = string                     # The type of the variable, in this case a string
  default     = "t2.micro"                 # Default value for the variable
  description = "The type of EC2 instance" # Description of what this variable represents
}
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

