output "private_key_preview" {
  value = substr(var.private_key, 0, 100)
}
