output "alb_dns_name" {
  description = "DNS público do Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN do Application Load Balancer."
  value       = aws_lb.main.arn
}

output "asg_name" {
  description = "Nome do Auto Scaling Group."
  value       = aws_autoscaling_group.web.name
}

output "target_group_arn" {
  description = "ARN do Target Group."
  value       = aws_lb_target_group.web.arn
}
