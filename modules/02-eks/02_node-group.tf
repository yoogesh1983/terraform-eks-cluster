/*
  Set up an IAM role for the worker nodes. The process is similar to the IAM role creation for the EKS cluster except this time the policies that you attach
  will be for the EKS worker node policies. The policies include:
    - AmazonEKSWorkerNodePolicy
    - AmazonEKS_CNI_Policy
    - EC2InstanceProfileForImageBuilderECRContainerBuilds
    - AmazonEC2ContainerRegistryReadOnly
*/


resource "aws_iam_role" "workernodes" {
  # The name of the role
  name = "eks-node-group-general"

  # The policy that grants an entity permission to assume the role
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.workernodes.name
 }


resource "aws_eks_node_group" "worker-node-group" {

  # Name of the eks cluster
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "worker-nodes"
  # Amazon Resource name (ARN) of the IAM role that provides permission for the eks
  node_role_arn = aws_iam_role.workernodes.arn

  # Identifies of ec2 subnets to associate with the EKS Node group
  # These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NANE where cluster name is replaced with
  # the name of the EKS cluster
  subnet_ids = [
      module.my-custom-vpc.subnet-private1,
      module.my-custom-vpc.subnet-private2
  ]

  # Configuration block with scaling settings
  scaling_config {
    # Desired number of worker nodes
    desired_size = 1
    # Maximum number of worker nodes
    max_size = 3
    # Minimum number of worker nodes
    min_size = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Type of amazon machine Image (IAM) associated with the eks node group
  # Valid values: AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64
  ami_type = "AL2_x86_64"

  # Type of capacity associated with the eks node group
  # valid values: ON_DEMAND, SPOT
  capacity_type = "ON_DEMAND"

  # Disk size in GiB for worker nodes (in a production environment, it should be 100 GB)
  disk_size = 20

  force_update_version = false

  #List of instance types associated with the EKS Node Group
  instance_types = ["t3.small"]

  labels = {
    "role" = "nodes-general"
  }

  # It will be inherited from latest master plane if you don't provide the version
  #version = "1.22"

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.EC2InstanceProfileForImageBuilderECRContainerBuilds,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}