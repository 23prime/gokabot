output "gokabot-nlb" {
  value = aws_lb.gokabot-nlb
}

output "gokabot-tg-01" {
  value = aws_lb_target_group.gokabot-tg-01
}

output "gokabot-tg-02" {
  value = aws_lb_target_group.gokabot-tg-02
}

output "gokabot-nlb-listener-443" {
  value = aws_lb_listener.gokabot-nlb-listener-443
}
