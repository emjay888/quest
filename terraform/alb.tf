# Create ALB
resource "aws_lb" "main" {
  name               = upper(var.project_name)
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets[var.aws_region]

  tags = {
    Name = upper(var.project_name)
  }
}

# Create TG
resource "aws_alb_target_group" "main_3000" {
  depends_on = [aws_lb.main]
  name       = "${upper(var.project_name)}-3000"
  port       = var.instance_application_port
  protocol   = "HTTP"
  vpc_id     = var.vpc_id[var.aws_region]

  tags = {
    Name = "${upper(var.project_name)}-3000"
  }
}

# Attach EC2 intances to TG
resource "aws_lb_target_group_attachment" "main_3000" {
  depends_on       = [aws_alb_target_group.main_3000]
  for_each         = local.ec2_nodes
  target_group_arn = aws_alb_target_group.main_3000.arn
  target_id        = module.ec2_instance[each.key].id
  port             = var.instance_application_port
}

# Create ALB Listener with port forwarding to EC2 Instances TG
resource "aws_alb_listener" "http" {
  count             = var.external_zone_name == "" ? 1 : 0
  depends_on        = [aws_lb.main]
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main_3000.id
    type             = "forward"
  }
}

# Create HTTPS ALB Listener with port forwarding to EC2 Instances TG
resource "aws_alb_listener" "https" {
  count             = var.external_zone_name == "" ? 0 : 1
  depends_on        = [aws_lb.main]
  load_balancer_arn = aws_lb.main.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = aws_acm_certificate_validation.service[0].certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.main_3000.id
    type             = "forward"
  }
}

# Create ALB SG
resource "aws_security_group" "alb" {
  name   = "${upper(var.project_name)}-ALB"
  vpc_id = var.vpc_id[var.aws_region]

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${upper(var.project_name)}-ALB"
  }
}
