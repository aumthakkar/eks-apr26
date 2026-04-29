# VPC Networking Outputs
output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "cluster_name" {
  value = aws_eks_cluster.my_eks_cluster.id
}

output "cluster_ca_certificate_data" {
  value = aws_eks_cluster.my_eks_cluster.certificate_authority[0].data
}

output "cluster_endpoint" {
  value = aws_eks_cluster.my_eks_cluster.endpoint
}