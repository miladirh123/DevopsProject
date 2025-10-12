resource "aws_instance" "devapp" {
  ami           = "ami-04c08fd8aa14af291"
  instance_type = "t3.micro"
  key_name      = "ec2-key"  # Nom exact de la clé AWS
  security_groups = [aws_security_group.ssh_access.name]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

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
      private_key = var.private_key
      host        = self.public_ip
      timeout     = "5m"
    }
  }
}
