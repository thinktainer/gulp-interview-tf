variable "availability_zone_names" {
  type = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "igw" {
  gateway_id = aws_internet_gateway.gw.id
  route_table_id = aws_vpc.main.main_route_table_id
}

resource "aws_subnet" "web-az-a" {
  vpc_id = aws_vpc.main.id
  availability_zone = var.availability_zone_names[0]
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "web-a"
  }
}

resource "aws_route_table_association" "web-az-a-rt" {
  subnet_id = aws_subnet.web-az-a.id
  route_table_id = aws_vpc.main.main_route_table_id
}

resource "aws_subnet" "web-az-b" {
  vpc_id = aws_vpc.main.id
  availability_zone = var.availability_zone_names[1]
  cidr_block = "10.0.2.0/24"
  
  tags = {
    Name = "web-b"
  }
}

resource "aws_route_table_association" "web-az-b-rt" {
  subnet_id = aws_subnet.web-az-b.id
  route_table_id = aws_vpc.main.main_route_table_id
}

resource "aws_subnet" "database-az-a" {
  vpc_id = aws_vpc.main.id
  availability_zone = var.availability_zone_names[0]
  cidr_block = "10.0.100.0/24"

  tags = {
    Name = "database-a"
  }
}

resource "aws_lb" "web-public" {
  name = "web-pub"
  internal = false
  load_balancer_type = "application"
  subnets = [aws_subnet.web-az-a.id, aws_subnet.web-az-b.id]
  enable_deletion_protection = true
  security_groups = [aws_security_group.lb.id]

  depends_on = [aws_internet_gateway.gw]

  access_logs {
    bucket = ""
    enabled = false
  }
}

resource "aws_lb_listener" "web-public" {
  load_balancer_arn = aws_lb.web-public.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web-public.arn
  }

}

resource "aws_security_group" "lb" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "web-public" {
  name = "web-public-lb-tg"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.main.id
}
