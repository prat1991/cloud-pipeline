# Creates ECR (image registry) + EC2 (server)
provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "app" {
  name = "cloud-pipeline-app"
  force_delete = true        # allows clean destroy + recreate
}

resource "aws_instance" "app" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.app.id]
  tags = { Name = "cloud-pipeline" }
}

resource "aws_security_group" "app" {
  name = "cloud-pipeline-sg"

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