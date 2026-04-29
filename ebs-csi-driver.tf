data "aws_eks_addon_version" "ebs_csi_driver_latest" {
  count = var.create_ebs_csi_controller ? 1 : 0

  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.my_eks_cluster.version

  most_recent = true
}

resource "aws_eks_addon" "ebs_csi_addon" {
  count = var.create_ebs_csi_controller ? 1 : 0

  cluster_name = aws_eks_cluster.my_eks_cluster.name

  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi_driver_latest[count.index].version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    controller = {
      replicaCount = 1
    }
  })
  
  depends_on = [
    aws_eks_addon.eks_pod_identity_agent,
    aws_eks_pod_identity_association.ebs_eks_pod_identity_association
  ]
}