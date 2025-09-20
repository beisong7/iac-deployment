# Outputs for Project Bedrock Infrastructure

# VPC Outputs
output "vpc_id" {
  description = "VPC ID where the cluster and RDS instances are deployed"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

# EKS Cluster Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

# Node Group Outputs
output "node_groups" {
  description = "EKS node groups"
  value       = module.eks.eks_managed_node_groups
}

# Security Group Outputs
output "node_security_group_id" {
  description = "Security group ID for EKS nodes"
  value       = aws_security_group.node_group_sg.id
}

output "rds_security_group_id" {
  description = "Security group ID for RDS instances"
  value       = aws_security_group.rds_sg.id
}

output "alb_security_group_id" {
  description = "Security group ID for Application Load Balancer"
  value       = aws_security_group.alb_sg.id
}

# IAM Role Outputs
output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "node_group_iam_role_name" {
  description = "IAM role name associated with EKS node group"
  value       = aws_iam_role.eks_node_group_role.name
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN associated with EKS node group"
  value       = aws_iam_role.eks_node_group_role.arn
}

# Developer User Outputs (Core Requirement)
output "developer_user_name" {
  description = "Name of the developer IAM user"
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

# Load Balancer Controller Role (Bonus Feature)
output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

# RDS Outputs (Bonus Features)
output "orders_db_endpoint" {
  description = "RDS instance endpoint for orders database"
  value       = try(aws_db_instance.orders_db[0].endpoint, "not_created")
}

output "catalog_db_endpoint" {
  description = "RDS instance endpoint for catalog database"
  value       = try(aws_db_instance.catalog_db[0].endpoint, "not_created")
}

# DynamoDB Outputs (Bonus Features)
output "dynamodb_table_name" {
  description = "DynamoDB table name for carts service"
  value       = try(aws_dynamodb_table.carts[0].name, "not_created")
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN for carts service"
  value       = try(aws_dynamodb_table.carts[0].arn, "not_created")
}

# Kubeconfig Command for Developer Access
output "kubeconfig_command" {
  description = "Command to configure kubectl for developers"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name} --profile developer"
}

# Application URLs (will be populated after deployment)
output "application_url" {
  description = "URL where the retail store application is accessible"
  value       = "Run 'kubectl get ingress' or 'kubectl get svc ui' after deployment to get the application URL"
}

# AWS CLI Commands for Developer Setup
output "developer_aws_configure_commands" {
  description = "Commands for developer to configure AWS CLI"
  value = [
    "aws configure set aws_access_key_id ${aws_iam_access_key.developer.id} --profile developer",
    "aws configure set aws_secret_access_key ${aws_iam_access_key.developer.secret} --profile developer",
    "aws configure set region ${var.aws_region} --profile developer",
    "aws configure set output json --profile developer"
  ]
  sensitive = true
}

# Deployment Summary
output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    cluster_name    = module.eks.cluster_name
    cluster_region  = var.aws_region
    vpc_id          = module.vpc.vpc_id
    node_groups     = length(module.eks.eks_managed_node_groups)
    developer_user  = aws_iam_user.developer.name
    databases       = {
      orders_db  = try(aws_db_instance.orders_db[0].endpoint != "", false)
      catalog_db = try(aws_db_instance.catalog_db[0].endpoint != "", false)
      carts_db   = try(aws_dynamodb_table.carts[0].name != "", false)
    }
  }
}