data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_version]
  }
}

resource "aws_security_group" "ec2_security_group" {
  description = "Allow traffic for EC2 Webservers"
  vpc_id      = var.vpc_id
}

resource "aws_instance" "deployment" {
  count                       = var.ec2_count
  ami                         = data.aws_ami.amazon_linux.id
  key_name                    = var.key_pair
  instance_type               = var.instance_type
  associate_public_ip_address = "false"
  subnet_id                   = element(var.private_subnet_ids, count.index)
  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
  user_data                   = <<-EOF_USER_DATA
              #!/bin/bash
              yum install docker -y
              systemctl start docker
              mkdir content
              TOKEN=$(curl --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 3600")
              PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 --header "X-aws-ec2-metadata-token: $TOKEN")
              cat <<HTML > content/index.html
              <!DOCTYPE html>
              <html>
                <body style="font-family:Arial, sans-serif;">
                  <h1>yo this is nginx</h1>
                  <p>private ip: $PRIVATE_IP</p>
                </body>
              </html>
              HTML

              docker run --name some-nginx \
                       -v $(pwd)/content:/usr/share/nginx/html \
                       -p 80:80 \
                       -d nginx
              EOF_USER_DATA
  tags = {
    Name = "deployment-instance"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = var.sg_ingress_rules

  security_group_id = aws_security_group.ec2_security_group.id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr_ipv4
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.ec2_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
