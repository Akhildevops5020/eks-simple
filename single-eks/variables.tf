variable "region" {
  description = "AWS region to deploy the EKS cluster"
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "Name for the EKS cluster"
  type        = string
  default     = "single-eks-cluster"
}
