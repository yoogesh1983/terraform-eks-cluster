/*
 Public and Private subnets: 
 ----------------------------
 This VPC has two public and private subnets. One public and one Private subnet are deployed to the same availability zone.
 The other public and private subnets are deployed to a second availability zone in the same region. We recommend this option for all production deployments.
 This option allows you to deploy your nodes to private subnets and allows kubernetes to deploy load balancers to the public subnets that can load balance
 traffic to pods running on nodes in the private subnets.
*/


resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.0.0/18"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  # A map of tags to assign to the resource
  tags = {
    "Name"                      = "public-us-east-1a"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }

}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.64.0/18"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  # A map of tags to assign to the resource
  tags = {
    "Name"                      = "public-us-east-1b"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }

}
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.128.0/18"
  availability_zone = "us-east-1a"

  # A map of tags to assign to the resource
  tags = {
    "Name"                            = "private-us-east-1a"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.192.0/18"
  availability_zone = "us-east-1a"

  # A map of tags to assign to the resource
  tags = {
    "Name"                            = "private-us-east-1b"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

}