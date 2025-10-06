provider "aws" {
  region = "us-east-1"
  access_key = "TON_AWS_ACCESS_KEY"
  secret_key = "TA_SECRET_KEY"
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-0c02fb55956c7d316" # Ubuntu 22.04 (exemple)
  instance_type = "t2.micro"
  key_name      = "jenkins-key"
  
  tags = {
    Name = "Jenkins-Server"
  }
}
