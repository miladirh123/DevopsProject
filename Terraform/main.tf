variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "devapp" {
  ami           = "ami-052064a798f08f0d3"
  instance_type = "t3.micro"
  key_name      = "ec2-key"

  tags = {
    Name = "DevAppInstance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install docker -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/ec2-key.pem")
      host        = self.public_ip
    }
  }
}

output "ec2_public_ip" {
  value = aws_instance.devapp.public_ip
}
