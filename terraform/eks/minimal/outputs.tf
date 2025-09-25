output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.retail_app_eks.eks_cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.retail_app_eks.cluster_endpoint
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${module.retail_app_eks.eks_cluster_id}"
}

output "vpc_id" {
  description = "ID of the VPC where the cluster is deployed"
  value       = module.vpc.inner.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.inner.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.inner.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.inner.public_subnets
}

output "node_security_group_id" {
  description = "ID of the node security group"
  value       = module.retail_app_eks.node_security_group_id
}

# Developer IAM User Outputs
output "developer_user_name" {
  description = "IAM username for developer access"
  value       = aws_iam_user.developer.name
}

output "developer_user_arn" {
  description = "ARN of the developer IAM user"
  value       = aws_iam_user.developer.arn
}

output "developer_access_key_id" {
  description = "Access key ID for developer user"
  value       = aws_iam_access_key.developer.id
  sensitive   = true
}

output "developer_secret_access_key" {
  description = "Secret access key for developer user"
  value       = aws_iam_access_key.developer.secret
  sensitive   = true
}

# Configuration instructions for developers
output "developer_kubeconfig_command" {
  description = "Command to configure kubectl for developer access"
  value = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.retail_app_eks.eks_cluster_id} --profile developer"
}

output "developer_setup_instructions" {
  description = "Setup instructions for developer access"
  sensitive   = true
  value = <<-EOT
# Developer Setup Instructions for EKS Cluster Access

## 1. Configure AWS CLI Profile
aws configure set aws_access_key_id ${aws_iam_access_key.developer.id} --profile developer
aws configure set aws_secret_access_key ${aws_iam_access_key.developer.secret} --profile developer
aws configure set region ${data.aws_region.current.name} --profile developer

## 2. Update kubeconfig
aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.retail_app_eks.eks_cluster_id} --profile developer

## 3. Test access (read-only operations)
kubectl get nodes
kubectl get pods -n retail-store
kubectl get services -n retail-store
kubectl logs -n retail-store deployment/ui

## 4. Available commands (read-only access)
- kubectl get <resource>
- kubectl describe <resource>
- kubectl logs <resource>
- kubectl exec <pod> -- <command> (for troubleshooting)

Note: This user has read-only access to the cluster. Write operations will be denied.
EOT
}

# Additional AWS data
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}