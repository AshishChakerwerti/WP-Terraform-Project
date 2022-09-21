locals {
  ami_id = "ami-09e67e426f25ce0d7"
  vpc_id = "vpc-0acf6308d5000f37c"
  ssh_user = "ubuntu"
  key_name = "WP-Key"
  private_key_path = "./WP-Key.pem"
}

provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAVPJKAZ3JRJZYBQLX"
  secret_key = "SIPJTmsNFjdvmxay+VQxxAuCGLM1gIuBtJJ62UiW"
  token = "FwoGZXIvYXdzEN3//////////wEaDJNFbpxobSmi4+GE0CK9AeYu0cc+iqyiBskMRrqTxKCm+nrjSzW8G/WQtSeclWHPQm+c8etB+WKDeZ1UEX41wa9pttH0Qu+2xfapvGpZi4sfSaTOK0lowaI5B/Psox/27TGaBA9xb8KxmPXID4wRZ1eH7Ux/4Ici1tF4XblYaN5vjAwkB+fCV11t1nGafQlZS4OVli7jrLETFVXMbW9lv88PJOmAL194pZO4Wxzi/og93XEZltWA9eZkUIkOHuSDCAU5Cj6gIb1dnWRRryim7quZBjItMW7pKmOrCiHfvSajNXjTI/fr/+cl9NUfDKmCRK/u7W8d8aXkgBVO8RIYeKnP"
}

resource "aws_security_group" "project2-wordpress" {
        name   = "project2-wordpress"
        vpc_id = local.vpc_id

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
  ingress {
                from_port   = 443
                to_port     = 443
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

resource "aws_instance" "WP" {
  ami = local.ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids =[aws_security_group.project2-wordpress.id]
  key_name = local.key_name
#   user_data = <<EOF
# #!/bin/bash
# sudo apt-get update && apt-get install ansible
# EOF
  connection {
    type = "ssh"
    host = self.public_ip
    user = local.ssh_user
    private_key = file(local.private_key_path)
    timeout = "4m"
  }

  provisioner "remote-exec" {
    inline = [
      "hostname"
    ]
  }
  
  
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > myhosts" 
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i myhosts --user ${local.ssh_user} --private-key ${local.private_key_path} install-wordpress.yml" 
  }

}

output "instance_ip" {
  value = aws_instance.WP.public_ip
}
