terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.74.0"
    }
  }
}



provider "aws" {
  # shared_config_files      = ["/root/.aws/config"]
  # shared_credentials_file = "/root/.aws/credentials"
  region = "us-east-1"
  # shared_credentials_file = "~/.aws/credentials"
  # access_key = var.access_key
  # secret_key = var.secret_key
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

#Create a policy
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  path        = "/"
  description = "Policy to provide permission to EC2"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
      Effect = "Allow"
      Action =["s3:*"]
      Resource = ["*"]
    }
  ]
  })
}

#Create a role
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com"}
      Action = "sts:AssumeRole"
    }
  ]
  })
}

#Attach role to policy
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment
resource "aws_iam_policy_attachment" "ec2_policy_role" {
  name       = "ec2_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

#Attach role to an instance profile
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_key_pair" "generated_key" {
  key_name   = "generated_key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "terraforminstance" {
  ami                         = "ami-09d56f8956ab235b3"
  instance_type               = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance1606.id]
  key_name                    = aws_key_pair.generated_key.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = "${file("script.sh")}"
 

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
      private_key = file("~/.ssh/id_rsa")
      # private_key = tls_private_key.example.private_key_pem
   }
}