# Creates ECR (image registry) + EC2 (server)
provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "app" {
  name         = "cloud-pipeline-app"
  force_delete = true        # allows clean destroy + recreate
}

resource "aws_security_group" "app" {
  name = "cloud-pipeline-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22          # FIX: open port 22 so SSH can connect
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
}

resource "aws_key_pair" "deployer" {
  key_name   = "cloud-pipeline-key"                        # FIX: create key pair so SSH can authenticate
  public_key = var.ec2_public_key
}

resource "aws_instance" "app" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = aws_key_pair.deployer.key_name  # FIX: attach key pair to EC2
  tags                   = { Name = "cloud-pipeline" }
}

variable "ec2_public_key" {}                               # FIX: receives public key from GitHub secret

# FIX: these output blocks were missing — without them terraform output returns nothing
output "ecr_uri" {
  value = aws_ecr_repository.app.repository_url
}

output "ec2_public_ip" {
  value = aws_instance.app.public_ip
}