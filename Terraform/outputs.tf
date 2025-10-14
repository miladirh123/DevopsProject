output "ec2_public_ip" {
  description = "Adresse IP publique de l'instance EC2"
  value       = aws_instance.devapp.public_ip
}
