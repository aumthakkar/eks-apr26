resource "aws_iam_role" "cw_obs_iam_role" {
  count = var.create_cw_observability_controller ? 1 : 0

   name = "${var.name_prefix}-cw-observability-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = "CWObservabilityDriverIAMRole"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.name_prefix}-cw-observability-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_CloudWatchAgentServerPolicy" {
  count = var.create_cw_observability_controller ? 1 : 0

  role = aws_iam_role.cw_obs_iam_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_AWSXrayWriteOnlyAccess" {
  count = var.create_cw_observability_controller ? 1 : 0

  role = aws_iam_role.cw_obs_iam_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_eks_pod_identity_association" "cw_eks_pod_identity_association" {
  count = var.create_cw_observability_controller ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.name
  namespace = "kube-system"

  role_arn = aws_iam_role.cw_obs_iam_role[count.index].arn
  service_account = "cloudwatch-agent"

  depends_on = [ 
    aws_eks_addon.eks_pod_identity_agent
   ]

}