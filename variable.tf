variable "region" {
  description = "AWS Region"
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "Base name used when creating per-environment EKS clusters"
  default     = "simple-eks-cluster"
}
