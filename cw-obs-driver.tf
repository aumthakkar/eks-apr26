data "aws_eks_addon_version" "cw_obs_driver_latest" {
  count = var.create_cw_observability_controller ? 1 : 0

  kubernetes_version = aws_eks_cluster.my_eks_cluster.version
  addon_name = "amazon-cloudwatch-observability"

  most_recent = true 
}

resource "aws_eks_addon" "cw_obs_addon" {
  count = var.create_cw_observability_controller ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.name

  addon_name = "amazon-cloudwatch-observability"
  addon_version = data.aws_eks_addon_version.cw_obs_driver_latest[count.index].version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  configuration_values = null

  depends_on = [ 
    aws_eks_addon.eks_pod_identity_agent,
    aws_eks_pod_identity_association.cw_eks_pod_identity_association
   ]
}