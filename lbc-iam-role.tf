resource "aws_iam_role" "lbc_iam_role" {
  count = var.create_lbc_controller ? 1: 0

   name = "${var.name_prefix}-lbc-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = "LBCDriverIAMRole"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.name_prefix}-lbc-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSLoadBalancingPolicy" {
  count = var.create_lbc_controller ? 1 : 0

  role = aws_iam_role.lbc_iam_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
}

resource "aws_eks_pod_identity_association" "lbc_eks_pod_identity_association" {
  count = var.create_lbc_controller ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.name
  namespace = "kube-system"

  role_arn = aws_iam_role.lbc_iam_role[count.index].arn
  service_account = "aws-load-balancer-controller"

}

