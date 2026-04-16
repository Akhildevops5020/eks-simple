terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  environments = {
    dev = {
      cidr            = "10.0.0.0/16"
      private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
      public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]
    }
    stage = {
      cidr            = "10.1.0.0/16"
      private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
      public_subnets  = ["10.1.3.0/24", "10.1.4.0/24"]
    }
    prod = {
      cidr            = "10.2.0.0/16"
      private_subnets = ["10.2.1.0/24", "10.2.2.0/24"]
      public_subnets  = ["10.2.3.0/24", "10.2.4.0/24"]
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

data "aws_eks_cluster_auth" "this" {
  for_each = module.eks

  name = each.value.cluster_name
}

provider "helm" {
  alias = "dev"

  kubernetes {
    host                   = module.eks["dev"].cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks["dev"].cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this["dev"].token
    load_config_file       = false
  }
}

provider "helm" {
  alias = "stage"

  kubernetes {
    host                   = module.eks["stage"].cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks["stage"].cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this["stage"].token
    load_config_file       = false
  }
}

provider "helm" {
  alias = "prod"

  kubernetes {
    host                   = module.eks["prod"].cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks["prod"].cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this["prod"].token
    load_config_file       = false
  }
}

resource "helm_release" "grafana_dev" {
  provider   = helm.dev
  name       = "grafana-dev"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "grafana-dev"

  create_namespace = true
}

resource "helm_release" "grafana_stage" {
  provider   = helm.stage
  name       = "grafana-stage"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "grafana-stage"

  create_namespace = true
}

resource "helm_release" "grafana_prod" {
  provider   = helm.prod
  name       = "grafana-prod"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "grafana-prod"

  create_namespace = true
}
