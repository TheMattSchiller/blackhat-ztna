resource "aws_lb" "controller" {
  name               = "${var.tag}-controller"
  load_balancer_type = "network"
  internal           = false
  subnets            = [var.public_subnet]

  tags = {
    Name = "${var.tag}-controller"
  }
}

resource "aws_lb_target_group" "controller" {
  name     = "${var.tag}-controller"
  port     = 9200
  protocol = "TCP"
  vpc_id   = var.vpc_id

  stickiness {
    enabled = false
    type    = "source_ip"
  }
  tags = {
    Name = "${var.tag}-controller"
  }
}

resource "aws_lb_target_group_attachment" "controller" {
  target_group_arn = aws_lb_target_group.controller.arn
  target_id        = aws_instance.controller.id
  port             = 9200
}

resource "aws_lb_listener_certificate" "boundary_https_ssl_cert" {
  listener_arn    = aws_lb_listener.controller.arn
  certificate_arn = aws_acm_certificate.cert.arn
}


resource "aws_lb_listener" "controller" {
  load_balancer_arn = aws_lb.controller.arn
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller.arn
  }
}

resource "aws_security_group" "controller_lb" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.tag}-controller-lb"
  }
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller_lb.id
}
