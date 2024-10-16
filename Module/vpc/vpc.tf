data "aws_availability_zones" "myaz" {
  state = "available"

}

resource "aws_vpc" "levelup_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name = "${var.env}-vpc"
  }

}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.levelup_vpc.id
  cidr_block              = var.public_subnet
  availability_zone       = data.aws_availability_zones.myaz.names[0]
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.env}-piblic-subnet"
  }
}


resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.levelup_vpc.id
  cidr_block        = var.private_subnet
  availability_zone = data.aws_availability_zones.myaz.names[1]

  tags = {
    Name = "${var.env}-private_subnet"
  }
    

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.levelup_vpc.id

  tags = {
    Name = "${var.env}-IGW"
  }

}

resource "aws_eip" "my-eip" {
  depends_on = [aws_internet_gateway.igw]

}

resource "aws_nat_gateway" "mynat" {
  allocation_id = aws_eip.my-eip.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.env}-NAT-GTW"
  }

}

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.levelup_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }

  tags = {
    Name = "${var.env}-public-route"
  }


}

resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.levelup_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.mynat.id
  }

  tags = {
    Name = "${var.env}-private-route"
  }

}

#Route table assoiation with public subnet
resource "aws_route_table_association" "public-route-association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public-route.id

}
#Route table assoiation with private subnet
resource "aws_route_table_association" "private-route-association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private-route.id

}



#Security Groups

resource "aws_security_group" "sg" {
  name   = "sg"
  vpc_id = aws_vpc.levelup_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
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
  Name = "${var.env}-security-group" }

}

output "security-group" {
  value = aws_security_group.sg.id

}

output "myvpc" {
  value = aws_vpc.levelup_vpc.id

}

output "publicsubnet" {
  value = aws_subnet.public.id

}

output "privatesubnet" {
  value = aws_subnet.private.id

}




