provider "aws" {
  region = var.region
}

locals {
  environments = {
    dev = {
      cidr             = "10.0.0.0/16"
      private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
      public_subnets   = ["10.0.3.0/24", "10.0.4.0/24"]
    }
    stage = {
      cidr             = "10.1.0.0/16"
      private_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
      public_subnets   = ["10.1.3.0/24", "10.1.4.0/24"]
    }
    prod = {
      cidr             = "10.2.0.0/16"
      private_subnets  = ["10.2.1.0/24", "10.2.2.0/24"]
      public_subnets   = ["10.2.3.0/24", "10.2.4.0/24"]
    }
  }
}

# VPC Creation
module "vpc" {
  for_each = local.environments

  source = "terraform-aws-modules/vpc/aws"

  name = "${each.key}-eks-simple-vpc"
  cidr = each.value.cidr

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = each.value.private_subnets
  public_subnets  = each.value.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
}

# EKS Cluster
module "eks" {
  for_each = local.environments

  source = "terraform-aws-modules/eks/aws"

  name               = "${var.cluster_name}-${each.key}"
  kubernetes_version = "1.29"

  vpc_id     = module.vpc[each.key].vpc_id
  subnet_ids = module.vpc[each.key].private_subnets

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      max_size       = 2
      min_size       = 1
      instance_types = ["t3.medium"]
    }
  }
}
