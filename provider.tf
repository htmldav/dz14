terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.74.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "instance1606" {
  description = "security group for ec2"
  ingress = [
    {
      # ssh port allowed from any ip
      description      = "ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
        {
      description      = "html"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
  egress = [
    {
      description      = "all-open"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
}

# resource "tls_private_key" "example" {
#   algorithm   = "RSA"
#   rsa_bits = 4096
# }

resource "aws_key_pair" "generated_key" {
  key_name   = "generated_key"
  public_key = "${file("/root/.ssh/id_rsa.pub")}"
  # public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "terraforminstance" {
  ami                         = "ami-09d56f8956ab235b3"
  instance_type               = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance1606.id]
  key_name                    = aws_key_pair.generated_key.key_name
 
  provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
    ]
  }
  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("/root/.ssh/id_rsa")
      # private_key = tls_private_key.example.private_key_pem
   }
}