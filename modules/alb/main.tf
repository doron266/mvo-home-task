resource "aws_security_group" "alb_security_group" {
  description = "Allow traffic for EC2 Webservers"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_ipv4" {
  security_group_id = aws_security_group.alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_lb" "application_load_balancer" {
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_security_group.id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "alb_target_group" {
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 20
    path                = "/"
    timeout             = 10
    matcher             = 200
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.id
  }
}

resource "aws_alb_target_group_attachment" "tg_attachment" {
  for_each = toset(var.target_instance_ids)

  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = each.value
  port             = 80
}
