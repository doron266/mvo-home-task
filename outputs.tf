output "instance_public_ip" {
  value       = ""                                          # The actual value to be outputted
  description = "The public IP address of the EC2 instance" # Description of what this output represents
}

output "alb_dns_name" {
  value = aws_lb.aws-application_load_balancer.dns_name
}
