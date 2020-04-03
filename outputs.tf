output "alb_hostname" {
  value = "${aws_alb.squad_chaws_alb.dns_name}"
}
