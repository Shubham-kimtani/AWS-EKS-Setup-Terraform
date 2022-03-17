

# Creation of IAM role for cluster and attaching 2 policies i.e.
# AmazonEKSClusterPolicy, AmazonEKSVPCResourceController
resource "aws_iam_role" "demo-cluster" {
  name = "terraform-eks-demo-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
# IAM Managed policy "AmazonEKSClusterPolicy" is attached to above created IAM role
resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo-cluster.name
}
# IAM Managed policy "AmazonEKSVPCResourceController" is attached to above created IAM role
resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.demo-cluster.name
}

# Creation of Security group for EKS Cluster that will be attached to previously created
# VPC
resource "aws_security_group" "demo-cluster" {
  name        = "terraform-eks-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.demo.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #   ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "terraform-eks-demo"
  }
}
# Inbound rule to be attached to above security group
resource "aws_security_group_rule" "allow_incoming_traffic" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allowed Traffic"
  from_port         = 0
  protocol          = "tcp"
  security_group_id = aws_security_group.demo-cluster.id
  to_port           = 65535
  type              = "ingress"
}

# Creation of EKS Cluster, attaching above created role to it, attaching VPC config that was
# created earlier.
resource "aws_eks_cluster" "demo" {
  name     = var.cluster-name
  role_arn = aws_iam_role.demo-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.demo-cluster.id]
    subnet_ids         = aws_subnet.demo[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSVPCResourceController,
  ]
}
