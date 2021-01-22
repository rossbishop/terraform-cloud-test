data "terraform_remote_state" "terraform-cloud-test" {
    backend = "remote"
    config = {
        organization = "art-site"
        workspaces = {
        name = "terraform-cloud-test"
        }
    }
}

provider "aws" {
    profile = "default"
    region  = "eu-west-2"
}

resource "aws_key_pair" "amazonlinux" {
    key_name   = "amazonlinux"
    public_key = file("key.pub")
}

resource "aws_security_group" "amazonlinux" {
    name        = "amazonlinux-security-group"
    description = "Allow HTTP, HTTPS and SSH traffic"

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
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

    tags = {
        Name = "terraform"
    }
}

resource "aws_instance" "amazonlinux" {
    key_name      = aws_key_pair.amazonlinux.key_name
    ami           = "ami-0e80a462ede03e653"
    instance_type = "t2.micro"
    user_data = "${file("setup_docker.sh")}"

    tags = {
        Name = "amazonlinux"
    }

    vpc_security_group_ids = [
        aws_security_group.amazonlinux.id
    ]

    connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = file("key")
        host        = self.public_ip
    }

    ebs_block_device {
        device_name = "/dev/xvda"
        volume_type = "gp2"
        volume_size = 8
    }

}