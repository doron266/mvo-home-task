variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "ec2_count" {
  type = number
}

variable "key_pair" {
  type = string
}

variable "ami_version" {
  type = string
}

variable "sg_ingress_rules" {
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_ipv4   = string
  }))
}
