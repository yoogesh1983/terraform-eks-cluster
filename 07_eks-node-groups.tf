resource "aws_iam_role" "nodes_general" {
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

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy_general" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes_general.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy_general" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes_general.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEC2ContainerRegistryReadOnly
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes_general.name
}

resource "aws_eks_node_group" "nodes_general" {

  # Name of the eks cluster
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "nodes-general"
  # Amazon Resource name (ARN) of the IAM role that provides permission for the eks
  node_role_arn = aws_iam_role.nodes_general.arn

  # Identifies of ec2 subnets to associate with the EKS Node group
  # These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NANE where cluster name is replaced with
  # the name of the EKS cluster
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
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
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy_general,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy_general,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]
}