output "cluster_names" {
  description = "Map of environment to EKS cluster name"
  value       = { for env, eks_module in module.eks : env => eks_module.cluster_name }
}

output "cluster_endpoints" {
  description = "Map of environment to EKS control plane endpoint"
  value       = { for env, eks_module in module.eks : env => eks_module.cluster_endpoint }
}
