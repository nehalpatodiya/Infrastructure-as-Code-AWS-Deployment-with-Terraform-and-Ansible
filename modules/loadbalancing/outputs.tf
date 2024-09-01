# --- loadbalancing/outputs.tf --- 

output "alb_dns" {
  value = aws_lb.custom_lb.dns_name
}

output "lb_endpoint" {
  value = aws_lb.custom_lb.dns_name
}

output "lb_tg_name" {
  value = aws_lb_target_group.custom_tg.name
}

output "lb_tg_arn" {
  value = aws_lb_target_group.custom_tg.arn
}