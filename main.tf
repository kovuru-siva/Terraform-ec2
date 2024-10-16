provider "aws" {
  region = "ap-south-1"

}

module "vpc" {
  source = "./Module/vpc"

}

module "ebsvlm" {
  source = "./Module/EBS"

}

resource "aws_instance" "web" {
  ami             = var.instance_ami
  instance_type   = lookup(var.instance-type, "ap-south-1", "t2.medium")
  subnet_id       = module.vpc.publicsubnet
  security_groups = [module.vpc.security-group]
  key_name        = aws_key_pair.my_key.webkey

  #User data to format and mount the EBS Volume
  user_data = <<-EOF
                #!/bin/bash
                mkfs -t ext4 /dev/xvdh
                mkdir /mnt/mydata
                mount /dev/xvdh /mnt/mydata
                echo "/dev/xvdh /mnt/mydata ext4 default,nofail 0 2" >> /etc/fstab
                EOF



  tags = {
    Name = "${var.ENV}-instance"
  }

}

resource "aws_volume_attachment" "example" {
  device_name = "/dev/sdh"
  volume_id   = module.ebsvlm.volume_id
  instance_id = aws_instance.web.id

}

# resource "aws_key_pair" "my_key" {
#   key_name   = "webkey"
#   public_key = file(var.public-key)


# }

resource "aws_key_pair" "my_key" {
  key_name   = "webkey"
  public_key = file(var.public-key)

}

output "public" {
  value = aws_instance.web.public_ip

}

output "key" {
  value = var.public-key

}

output "sgname" {
  value = module.vpc.security-group

}

