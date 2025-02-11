provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

resource "aws_instance" "nginx_server" {
  ami           = "ami-085ad6ae776d8f09c"  # Amazon Linux 2 AMI (us-east-1)
  instance_type = "t2.micro"
  key_name      = "your-key-pair-name"     # Replace with your EC2 key pair name

  tags = {
    Name = "nginx-server"
  }

  # Security group to allow SSH and HTTP traffic
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
}

resource "aws_security_group" "nginx_sg" {
  name_prefix = "nginx-sg-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (restrict in production)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

output "public_ip" {
  value = aws_instance.nginx_server.public_ip
}