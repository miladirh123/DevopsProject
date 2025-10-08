variable "private_key" {
  type        = string
  description = "Clé privée SSH pour se connecter à EC2"
}

resource "aws_instance" "devapp" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = "ec2-key"

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

output "ec2_public_ip" {
  value = aws_instance.devapp.public_ip
}
