# Security Groups for Project Bedrock

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "innovatemart-eks-cluster-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "innovatemart-eks-cluster-sg"
    Environment = "production"
    Project     = "bedrock"
  }
}

# EKS Node Group Security Group
resource "aws_security_group" "node_group_sg" {
  name_prefix = "innovatemart-eks-nodes-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Node to node"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description     = "Cluster to node"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  ingress {
    description     = "Cluster API to node"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "innovatemart-eks-nodes-sg"
    Environment = "production"
    Project     = "bedrock"
  }
}

# RDS Security Group (for bonus features)
resource "aws_security_group" "rds_sg" {
  name_prefix = "innovatemart-rds-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "MySQL/Aurora"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.node_group_sg.id]
  }

  ingress {
    description     = "PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.node_group_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "innovatemart-rds-sg"
    Environment = "production"
    Project     = "bedrock"
  }
}

# DB Subnet Group for RDS
resource "aws_db_subnet_group" "main" {
  name       = "innovatemart-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "innovatemart-db-subnet-group"
    Environment = "production"
    Project     = "bedrock"
  }
}

# Load Balancer Security Group (for bonus networking features)
resource "aws_security_group" "alb_sg" {
  name_prefix = "innovatemart-alb-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "innovatemart-alb-sg"
    Environment = "production"
    Project     = "bedrock"
  }
}