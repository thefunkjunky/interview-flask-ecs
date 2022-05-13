resource "aws_alb" "application_load_balancer" {
  name               = "${local.env_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc_networking.public_subnet_ids
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = {
    Name        = "${local.env_prefix}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${local.env_prefix}-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc_networking.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "20"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "10"
    path                = "/api/foo"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${local.env_prefix}-lb-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}

