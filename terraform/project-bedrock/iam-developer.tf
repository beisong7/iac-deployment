# Developer user with read-only EKS access
resource "aws_iam_user" "developer" {
  name = "innovatemart-developer"
  path = "/developers/"

  tags = {
    Environment = "production"
    Project = "bedrock"
  }
}

resource "aws_iam_user_access_key" "developer" {
  user = aws_iam_user.developer.name
}

resource "aws_iam_policy" "eks_developer_policy" {
  name        = "EKSDeveloperReadOnly"
  path        = "/developers/"
  description = "Read-only access to EKS resources"

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
          "eks:ListUpdates"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "developer_eks_policy" {
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.eks_developer_policy.arn
}