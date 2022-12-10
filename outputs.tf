output "password" {
  description = "Local Admin Password"
  value = [
    for g in aws_instance.unica_servers : rsadecrypt(g.password_data, file(var.private_key))
  ]

}
