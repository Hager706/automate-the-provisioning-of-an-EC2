provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "nginx_sg" {
  name_prefix = "nginx-sg"
  
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
}

# resource "aws_key_pair" "name" {
  
# }

# 3 to make

resource "aws_instance" "nginx_instance" {
  ami           = "ami-085ad6ae776d8f09c"  
  instance_type = "t2.micro"
  key_name      = "my-key" 
  security_groups = [aws_security_group.nginx_sg.name]

  tags = {
    Name = "nginx-server"
  }
}

output "public_ip" {
  value = aws_instance.nginx_server.public_ip
}

