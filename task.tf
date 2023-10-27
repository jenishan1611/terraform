# Define the AWS provider block
provider "aws" {
  region = "ap-south-1" # Replace with your desired region
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" # You can choose your own CIDR block
}

# Create three subnets in three different AZs
resource "aws_subnet" "subnet1" {
  count                   = 3
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = element(["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"], count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true # Enable auto-assign public IP
}

# Create security group for instances
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Security group for instances"
  vpc_id      = aws_vpc.my_vpc.id

  # Define ingress and egress rules as needed
  # Example: allow SSH and HTTP traffic
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
}

# Launch two instances in two different subnets
resource "aws_instance" "instance1" {
  ami           = "ami-0287a05f0ef0e9d9a" # Replace with your desired AMI ID
  instance_type = "t2.micro"    # Choose an appropriate instance type
  subnet_id     = aws_subnet.subnet1[0].id
  security_groups = [aws_security_group.instance_sg.id]
}

resource "aws_instance" "instance2" {
  ami           = "ami-0287a05f0ef0e9d9a" # Replace with your desired AMI ID
  instance_type = "t2.micro"    # Choose an appropriate instance type
  subnet_id     = aws_subnet.subnet1[1].id
  security_groups = [aws_security_group.instance_sg.id]
}

# Data source to fetch available AZs in the region
data "aws_availability_zones" "available" {}

# Output the public IPs of the instances
output "instance1_public_ip" {
  value = aws_instance.instance1.public_ip
}

output "instance2_public_ip" {
  value = aws_instance.instance2.public_ip
}

