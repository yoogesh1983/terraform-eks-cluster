/* -----------------------------------
  Step 1: Create a vpc
  ----------------------------------- */
resource "aws_vpc" "main" {
  # The CIDR block for the vpc
  cidr_block = "192.168.0.0/16"
  # makes your instances shared on the host
  instance_tenancy = "default"
  #Required for EKS. Enable/disalbe DNS support in the vpc
  enable_dns_support = true
  #Required for EKS. Enable/disalbe DNS hostnames in the vpc
  enable_dns_hostnames             = true
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "yms-custom-vpc"
  }
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
  sensitive   = false
}