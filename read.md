# Simple EKS Cluster using Terraform

## Prerequisites
- Terraform installed
- AWS CLI configured
- kubectl installed

## Steps to Run

1. Initialize Terraform
terraform init

2. Plan
terraform plan

3. Apply
terraform apply

4. Connect to EKS
aws eks update-kubeconfig --region ap-south-1 --name simple-eks-cluster

5. Verify
kubectl get nodes
