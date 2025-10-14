provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_security_group" "ssh_http_access" {
  name        = "ssh-http-access-${random_id.suffix.hex}"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "SSH-HTTP-Access"
  }
}

resource "aws_instance" "devapp" {
  ami           = "ami-04c08fd8aa14af291"
  instance_type = "t3.micro"
  key_name      = "ec2-key"
  security_groups = [aws_security_group.ssh_http_access.name]

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
      "sudo systemctl enable docker",
      "docker pull rahmam123/devapp",
      "docker stop devapp || true",
      "docker rm devapp || true",
      "docker run -d --name devapp -p 80:3000 rahmam123/devapp"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("C:/jenkins/keys/ec2-key.pem")
      host        = self.public_ip
      timeout     = "5m"
    }
  }

  depends_on = [aws_security_group.ssh_http_access]
}




