# Single EKS Cluster (t3.small)

This folder contains Terraform configuration to provision a single Amazon EKS cluster on `t3.small` managed nodes in `ap-south-1`.

## Usage

```bash
cd single-eks
terraform init
terraform plan
terraform apply
```

After `apply`, update your kubeconfig:

```bash
aws eks update-kubeconfig --region ap-south-1 --name single-eks-cluster
kubectl get nodes
```
