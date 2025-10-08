provider "aws" {
  region     = "us-east-1" 
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
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
