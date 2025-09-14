# IAM Role for Hello-World pod using Pod Identity
resource "aws_iam_role" "hello_world_pod_identity" {
  name = "hello-world-pod-identity-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })

  tags = var.tags
}

# Attach the same policies as the IRSA role for consistency
resource "aws_iam_role_policy_attachment" "hello_world_pod_identity_s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.hello_world_pod_identity.name
}

# Attach secrets access policy (same as IRSA setup)
resource "aws_iam_role_policy_attachment" "hello_world_pod_identity_secrets" {
  policy_arn = var.secrets_policy_arn
  role       = aws_iam_role.hello_world_pod_identity.name
}
