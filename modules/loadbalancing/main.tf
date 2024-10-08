# --- loadbalancing/main.tf ---


# INTERNET FACING LOAD BALANCER

resource "aws_lb" "custom_lb" {
  name            = "custom-loadbalancer"
  security_groups = [var.lb_sg]
  subnets         = var.public_subnets
  idle_timeout    = 400

  depends_on = [
    var.webserver_asg
  ]
}

resource "aws_lb_target_group" "custom_tg" {
  name     = "custom-lb-tg"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id

  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "custom_lb_listener" {
  load_balancer_arn = aws_lb.custom_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.custom_tg.arn
  }
}