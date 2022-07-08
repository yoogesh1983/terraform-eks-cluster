resource "aws_iam_role" "eks_cluster" {
  name = "eks_cluster"

  /*
   - The policy grants an entity permission to assume the rule
   - Used to access AWS resources thatyou might notnormallly have acces to
   - The rule that Amazon EKS will use to create AWS for kubernetes clusters
  */
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

resource "aws_iam_role_policy_attachment" "amzaon_eks_cluster_policy" {

  #The ARN of the policy you want to apply
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSClusterPolicy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

  # The role of the policy should be applied to
  role = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "eks" {
  name = "eks"

  # Amazon Resource Name (ARN) of the IAM role that provides permission for
  # the kubernetes control-plan to make calls to AWS API operations on your behalf
  role_arn = aws_iam_role.eks_cluster.arn

  # Desired kubernetes version (**** MUST BE UPDATD TO BE IN A VARIABLE ****)
  #version = "1.22"

  vpc_config {
    # Indicates whether or not the Amazon EKS private API server endpoint is enabled
    endpoint_private_access = false

    # Indicates whether or not the Amazon EKS public API server endpoint is enabled
    endpoint_public_access = true

    # Must be in at least two different availability zones
    subnet_ids = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id,
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted after eks cluster
  # Otherwise, EKS will not be able to properly delete EKS maages ec2 infrastructure 
  depends_on = [
    aws_iam_role_policy_attachment.amzaon_eks_cluster_policy
  ]

}