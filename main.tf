resource "aws_key_pair" "my_key_pair" {
    key_name = var.aws_key_name 
    public_key = file(var.public_key_path)
}
resource "aws_security_group" "my_security_group" {
    name = "My_security_group"
    description = "Allow SSH and HTTP traffic"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    ingress {
        from_port = 8000
        to_port = 8000
        description = "Allow traffic for argocd web interface"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    ingress {
        from_port = 8081
        to_port = 8081
        description = "allow traffic for sonarkube web interface"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        description = "allow traffic for jenkins web interface"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
    
}
resource "aws_instance" "my_instance" {
    key_name = aws_key_pair.my_key_pair.key_name
    security_groups = [aws_security_group.my_security_group.name]
    ami = var.aws_ami
    instance_type = var.aws_instance_type
    user_data = file("${path.module}/user_data.sh")
    root_block_device { 
        volume_size = var.root_volume_size
        volume_type = "gp3"

    }
    tags = {
        Name = "MY-EC2-Instance"
        Env = "Dev"
    }
}




