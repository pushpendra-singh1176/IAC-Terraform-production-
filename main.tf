resource "aws_key_pair" "my_key_pair" {
  key_name   = var.aws_key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "my_security_group" {
  name        = "My_security_group"
  description = "Allow SSH and HTTP traffic"

  # YAHAN ADD KARO: Taaki SG naye VPC mein bane
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow trafic for port 9000 sonarqube"
  }

  # ... baaki saare ingress rules (80, 8000, 8081, 8080) same rahenge ...

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_instance" {
  ami                         = var.aws_ami
  instance_type               = var.aws_instance_type
  key_name                    = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true # <--- Ye line IP lekar aayegi
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.my_security_group.id]
  user_data                   = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "MY-EC2-Instance"
    Env  = "Dev"
  }
}