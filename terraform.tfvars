sg_ingress_rules = {
  ssh = {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
  }
  http = {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
  }
}

