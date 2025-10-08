variable "aws_access_key" {
  type        = string
  description = "Clé d'accès AWS"
}

variable "aws_secret_key" {
  type        = string
  description = "Clé secrète AWS"
}

variable "private_key" {
  type        = string
  description = "Clé privée SSH pour provisioner EC2"
}
