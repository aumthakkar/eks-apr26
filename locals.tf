locals {
  public_cidr  = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_cidr = [for i in range(1, 255, 2) : cidrsubnet((var.vpc_cidr), 8, i)]
}

locals {
  cluster_subnet_ids   = aws_subnet.my_private_subnets[*].id
  nodegroup_subnet_ids = aws_subnet.my_private_subnets[*].id
}

locals {
  security_groups = {
    public_sg = {
      name        = "${var.name_prefix}-public-sg"
      description = "${var.name_prefix}-Public-Security-group"
      tags = {
        Name = "${var.name_prefix}-public-sg"
      }
      ingress = {
        ssh = {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["5.71.198.252/32"]
        }
      }
    }
  }
}

