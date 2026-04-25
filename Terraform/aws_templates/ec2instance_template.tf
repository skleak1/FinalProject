resource "aws_key_pair" "ec2-key" {
  key_name   = "ec2-key"
  public_key = file("${path.root}/ec2-key.pub")
}

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "ec2-sg" {
  name        = "Allow Port 5000 and 22"
  description = "Open Port 5000 and 22"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Open Port 5000 For Incoming Traffic"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Open Port 22 For Incoming Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all traffic from EC2 to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "website_server" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  key_name               = aws_key_pair.ec2-key.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = {
    Name = "${var.my_env}-app-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt upgrade -y
              sudo apt install -y docker.io
              git clone https://github.com/chanmuk1/EC2-Monitor-Grafana-Prometheus.git || true
              sudo curl -L \
              "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o \
              /usr/local/bin/docker-compose
              EOF
}

output "ec2_public_ip" {
  value = aws_instance.website_server[0].public_ip
}
