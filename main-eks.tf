resource "aws_eks_cluster" "my_eks_cluster" {
  name = var.cluster_name

  role_arn = aws_iam_role.cluster_role.arn
  version  = var.cluster_version

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    public_access_cidrs = var.public_acccess_cidrs
    subnet_ids          = local.cluster_subnet_ids
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.k8s_service_ipv4_cidr
  }

  # access_config {
  #   authentication_mode = "API_AND_CONFIG_MAP"
  #   bootstrap_cluster_creator_admin_permissions = true
  # }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_AmazonEKSVPCResourceController
  ]

  tags = {
    Name = "${var.name_prefix}-EKS-Cluster"
  }
}

resource "aws_eks_node_group" "my_eks_nodegroup" {
  cluster_name    = aws_eks_cluster.my_eks_cluster.name
  node_group_name = "${var.name_prefix}-EKS-Cluster-Nodegroup"

  node_role_arn = aws_iam_role.my_eks_nodegroup_role.arn
  subnet_ids    = local.nodegroup_subnet_ids

  ami_type       = var.nodegroup_ami_type
  capacity_type  = var.nodegroup_capacity_type
  instance_types = var.nodegroup_instance_types
  disk_size      = var.nodegroup_disk_size

  scaling_config {
    desired_size = var.nodegroup_desired_size
    max_size     = var.nodegroup_max_size
    min_size     = var.nodegroup_min_size
  }

  update_config {
    max_unavailable_percentage = var.max_unavailable_nodes_percentage
  }


  depends_on = [
    aws_iam_role_policy_attachment.eks_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_AmazonSSMManagedInstanceCore
  ]

  tags = {
    Name = "${var.name_prefix}-eks-nodegroup-role"
  }
}

