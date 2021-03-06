provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

// Ubuntu 14.04 official hvm:ebs volumes to their region.
variable "aws_amis" {
  default = {
    ap-northeast-1 = "ami-926091f3"
    ap-south-1 = "ami-fc92f893"
    ap-southeast-1 = "ami-2b28fa48"
    eu-central-1 = "ami-7dd03b12"
    eu-west-1 = "ami-a4b12bd7"
    sa-east-1 = "ami-d852c7b4"
    us-east-1 = "ami-8446ff93"
    us-west-1 = "ami-c72562a7"
  }
}

resource "aws_vpc" "terraform" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags { Name = "terraform" }
}

resource "aws_internet_gateway" "terraform" {
  vpc_id = "${aws_vpc.terraform.id}"
  tags { Name = "terraform" }
}

resource "aws_subnet" "terraform" {
  vpc_id = "${aws_vpc.terraform.id}"
  cidr_block = "10.0.0.0/24"
  tags { Name = "terraform" }
  availability_zone = "${var.aws_availability_zone}"

  map_public_ip_on_launch = true
}

resource "aws_route_table" "terraform" {
  vpc_id = "${aws_vpc.terraform.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terraform.id}"
  }

  tags { Name = "terraform" }
}

// The Route Table Association binds our subnet and route together.
resource "aws_route_table_association" "terraform" {
  subnet_id = "${aws_subnet.terraform.id}"
  route_table_id = "${aws_route_table.terraform.id}"
}

// The AWS Security Group is akin to a firewall. It specifies the inbound
// only open required ports in a production environment.
resource "aws_security_group" "terraform" {
  name   = "terraform-web"
  vpc_id = "${aws_vpc.terraform.id}"

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
