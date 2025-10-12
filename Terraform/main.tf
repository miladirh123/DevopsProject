provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh-access"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSHAccess"
  }
}

resource "aws_instance" "devapp" {
  ami           = "ami-04c08fd8aa14af291"
  instance_type = "t3.micro"
  key_name      = "ec2-key"
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
