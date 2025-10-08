provider "aws" {
  region     = "us-east-1" # Assure-toi que cette région correspond à ton compte AWS
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

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

resource "aws_instance" "devapp" {
  ami           = "ami-052064a798f08f0d3" # ← AMI valide que tu as fourni
  instance_type = "t3.micro"              # ← Compatible avec Free Tier
  key_name      = "ec2-key"               # ← Nom de ta paire de clés créée sur AWS

  tags = {
    Name = "DevAppInstance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install docker.io -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.private_key
      host        = self.public_ip
    }
  }
}
