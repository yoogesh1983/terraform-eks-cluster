/* 
  Set up the first resource for the IAM role. This ensures that the role has access to EKS 
*/
resource "aws_iam_role" "IAM-role-for-eks" {
  name = "yms-eks-IAM-role"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

/*
   Once the role is created, attach these two policies to it:
      - AmazonEKSClusterPolicy
      - AmazonEC2ContainerRegistryReadOnly-EKS
   These two policies allow you to properly access EC2 instances (where the worker nodes run) and EKS.
*/
resource "aws_iam_role_policy_attachment" "amzaon_eks_cluster_policy" {
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSClusterPolicy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.IAM-role-for-eks.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role = aws_iam_role.IAM-role-for-eks.name
}


/*
  Once the policies are attached, create the EKS cluster
*/
resource "aws_eks_cluster" "eks" {
  name = "eks"

  # Amazon Resource Name (ARN) of the IAM role that provides permission for the kubernetes control-plan to make calls to AWS API operations on your behalf
  role_arn = aws_iam_role.IAM-role-for-eks.arn

  # Desired kubernetes version (**** MUST BE UPDATD TO BE IN A VARIABLE ****)
  #version = "1.22"

  vpc_config {
    # Indicates whether or not the Amazon EKS private API server endpoint is enabled
    endpoint_private_access = false

    # Indicates whether or not the Amazon EKS public API server endpoint is enabled
    endpoint_public_access = true

    # Must be in at least two different availability zones
    subnet_ids = [
      module.my-custom-vpc.subnet-public1,
      module.my-custom-vpc.subnet-public2,
      module.my-custom-vpc.subnet-private1,
      module.my-custom-vpc.subnet-private2
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted after eks cluster
  # Otherwise, EKS will not be able to properly delete EKS maages ec2 infrastructure 
  depends_on = [
    aws_iam_role.IAM-role-for-eks,
    aws_iam_role_policy_attachment.amzaon_eks_cluster_policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly-EKS
  ]

}
