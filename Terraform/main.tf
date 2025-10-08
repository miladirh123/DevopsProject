provider "aws" {
  region     = "us-east-1" # ✅ Région compatible avec Free Tier et t2.micro
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "devapp" {
  ami           = "ami-0c02fb55956c7d316" # ✅ Amazon Linux 2 AMI compatible Free Tier dans us-east-1
  instance_type = "t2.micro"              # ✅ Type gratuit dans Free Tier
  key_name      = "ec2-key"               # ✅ Paire de clés que tu as créée

  tags = {
    Name = "DevAppInstance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install docker -y",
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
