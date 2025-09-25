data "aws_eks_cluster_auth" "this" {
  name = module.retail_app_eks.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.retail_app_eks.eks_cluster_id
}