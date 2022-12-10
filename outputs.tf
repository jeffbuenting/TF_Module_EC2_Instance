output "password" {
  description = "Local Admin Password"
  value = [
    for g in aws_instance.instance : rsadecrypt(g.password_data, file(var.private_key))
  ]

}
