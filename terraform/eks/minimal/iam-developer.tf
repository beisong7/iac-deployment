# Developer IAM user for read-only access to EKS cluster
resource "aws_iam_user" "developer" {
  name = "${var.environment_name}-developer"
  path = "/"

  tags = module.tags.result
}

resource "aws_iam_access_key" "developer" {
  user = aws_iam_user.developer.name
}

# IAM policy for EKS read-only access
resource "aws_iam_policy" "eks_readonly" {
  name        = "${var.environment_name}-eks-readonly"
  path        = "/"
  description = "Read-only access to EKS cluster resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeUpdate",
          "eks:ListUpdates",
          "eks:DescribeFargateProfile",
          "eks:ListFargateProfiles",
          "eks:ListAddons",
          "eks:DescribeAddon",
          "eks:DescribeAddonVersions",
          "eks:ListTagsForResource"
        ]
        Resource = [
          module.retail_app_eks.cluster_arn,
          "${module.retail_app_eks.cluster_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeNetworkInterfaces"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      }
    ]
  })

  tags = module.tags.result
}

# Attach the EKS read-only policy to the developer user
resource "aws_iam_user_policy_attachment" "developer_eks_readonly" {
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.eks_readonly.arn
}

# Kubernetes RBAC for read-only access
resource "kubernetes_cluster_role" "developer_readonly" {
  depends_on = [module.retail_app_eks]
  
  metadata {
    name = "developer-readonly"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "pods/status", "services", "endpoints", "namespaces", "nodes", "events"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "daemonsets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses", "networkpolicies"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "developer_readonly" {
  depends_on = [kubernetes_cluster_role.developer_readonly]
  
  metadata {
    name = "developer-readonly-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.developer_readonly.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = aws_iam_user.developer.name
    api_group = "rbac.authorization.k8s.io"
  }
}

# ConfigMap for AWS auth to map IAM user to Kubernetes user
resource "kubernetes_config_map_v1_data" "aws_auth" {
  depends_on = [module.retail_app_eks]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapUsers = yamlencode([
      {
        userarn  = aws_iam_user.developer.arn
        username = aws_iam_user.developer.name
        groups   = ["system:authenticated"]
      }
    ])
  }

  force = true
}