/* -----------------------------------
  Step 2: Create an internet gateway
  ----------------------------------- */
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "main"
  }
}
