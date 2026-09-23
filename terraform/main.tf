# PDF used us-east-1 + a hardcoded AMI/t2.micro; adapted to the lab account's region (eu-north-1),
# where t2.micro doesn't exist and AMI IDs differ.
provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("${path.module}/../ansible/my-key.pem.pub")
}

resource "aws_security_group" "devops_sg" {
  name = "devops-lab-sg"
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

resource "aws_instance" "devops_server" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  tags = {
    Name = "DevOps-Lab-Server"
  }
}

output "public_ip" {
  value = aws_instance.devops_server.public_ip
}
