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
 
  # provisioner "remote-exec" {
  #   inline = [
  #     "touch hello.txt",
  #     "echo helloworld remote provisioner >> hello.txt",
  #   ]
  # }

  user_data = <<-EOF
                #! /bin/bash
                sudo apt-get update
                sudo apt-get install -y python3-pip
                sudo pip install boto3
                sudo pip install botocore
                sudo apt-get install -y awscli
                sudo apt-get install -y default-jdk
                sudo apt-get install -y maven
        EOF

  # _____________________________________________
#     - name: Ensure pip3 is present
#     apt:
#       name: python3-pip
#       state: present

#   - name: Install boto3 and botocore with pip3 module
#     pip:
#       name: 
#       - boto3
#       - botocore
#       state: present

#   - name: Ensure awscli is present
#     apt:
#       name: awscli
#       state: present

# - hosts: deploy
#   become: yes

#   tasks:

#   - name: Ensure maven is present
#     apt:
#       name: maven
#       state: present

#   - name: Ensure git is present
#     apt:
#       name: git
#       state: present

#   - name: Clone a github repository
#     git:
#       repo: https://github.com/boxfuse/boxfuse-sample-java-war-hello
#       dest: /home/ubuntu/repos/
#       clone: yes
#       update: yes

#   - name: "source code : local install"
#     command: mvn --batch-mode --quiet install
#     args:
#       chdir: "/home/ubuntu/repos"

#   - name: Simple PUT operation
#     amazon.aws.aws_s3:
#       aws_access_key: "{{ec2_access_key}}"
#       aws_secret_key: "{{ec2_secret_key}}"
#       bucket: test12062022
#       object: hello-1.0.war
#       src: /home/ubuntu/repos/target/hello-1.0.war
#       mode: put
  
  # ___________________________

  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("/root/.ssh/id_rsa")
      # private_key = tls_private_key.example.private_key_pem
   }
}