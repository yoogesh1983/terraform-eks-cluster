resource "aws_eip" "nat1" {
  # EIP may require IGW to exist prior to association.
  # Use depends_on to set an explicit dependency on the IGW
  depends_on = [
    # This is referenced from our internet-gateway.tf file
    aws_internet_gateway.main
  ]
}

resource "aws_eip" "nat2" {
  depends_on = [
    aws_internet_gateway.main
  ]
}


resource "aws_nat_gateway" "gw1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public_1.id
  tags = {
    "Name" = "NAT 1"
  }
}

resource "aws_nat_gateway" "gw2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public_2.id
  tags = {
    "Name" = "NAT 2"
  }
}