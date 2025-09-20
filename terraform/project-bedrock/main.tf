# VPC Configuration
   module "vpc" {
     source = "terraform-aws-modules/vpc/aws"
     version = "~> 5.0"

     name = "innovatemart-vpc"
     cidr = "10.0.0.0/16"

     azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
     private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
     public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

     enable_nat_gateway = true
     enable_vpn_gateway = false
     enable_dns_hostnames = true
     enable_dns_support = true

     tags = {
       Environment = "production"
       Project = "bedrock"
       "kubernetes.io/cluster/innovatemart-eks" = "shared"
     }

     public_subnet_tags = {
       "kubernetes.io/cluster/innovatemart-eks" = "shared"
       "kubernetes.io/role/elb" = "1"
     }

     private_subnet_tags = {
       "kubernetes.io/cluster/innovatemart-eks" = "shared"
       "kubernetes.io/role/internal-elb" = "1"
     }
   }

   # EKS Cluster
   module "eks" {
     source = "terraform-aws-modules/eks/aws"
     version = "~> 19.0"

     cluster_name    = "innovatemart-eks"
     cluster_version = "1.28"

     vpc_id                         = module.vpc.vpc_id
     subnet_ids                     = module.vpc.private_subnets
     cluster_endpoint_public_access = true

     eks_managed_node_groups = {
       main = {
         name = "innovatemart-nodes"

         instance_types = ["t3.medium"]
         
         min_size     = 2
         max_size     = 4
         desired_size = 3

         vpc_security_group_ids = [aws_security_group.node_group_sg.id]
       }
     }

     tags = {
       Environment = "production"
       Project = "bedrock"
     }
   }