resource "helm_release" "lbc_helm_release" {
  count = var.create_lbc_controller ? 1 : 0

  name       = "${var.name_prefix}-lb-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"  
  chart      = "aws-load-balancer-controller"
  version    = "3.2.2"

  set = [
    {
      name  = "image.repository"
      value = "602401143452.dkr.ecr.eu-north-1.amazonaws.com/amazon/aws-load-balancer-controller"
    },
    {
      name = "image.tag"
      value = "v3.2.2"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name = "clusterName"
      value = "${aws_eks_cluster.my_eks_cluster.name}"
    },
    {
      name = "vpcId"
      value = "${aws_vpc.my_vpc.id}"
    },
    {
      name = "region"
      value = "${var.region}"
    }
  ]
  
  depends_on = [ 
    aws_eks_addon.eks_pod_identity_agent,
    aws_eks_pod_identity_association.lbc_eks_pod_identity_association
   ]
}