# Simple Multi-Environment EKS Deployment

## Overview
- `main.tf` configures AWS, defines three environments (dev/stage/prod), instantiates VPC + EKS modules per environment, and deploys a Grafana Helm release into each cluster.
- `variable.tf` declares shared inputs like AWS region and the base cluster name.
- `terraform.tfvars` supplies default values for those variables.
- `outputs.tf` exposes the cluster names and endpoints for each environment.
- `.terraform.lock.hcl` pins provider versions; `.gitignore` excludes state files.

## Usage
1. Initialize providers/modules: `terraform init`
2. Review changes: `terraform plan`
3. Apply infrastructure: `terraform apply`
4. Update kubeconfig (example for dev): `aws eks update-kubeconfig --region ap-south-1 --name <base-name>-dev`
5. Verify nodes: `kubectl get nodes`
6. Check Grafana Helm releases (example): `helm list -n grafana-dev`
