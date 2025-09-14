# IAM Role for Hello-World pod (OIDC-dependent)
resource "aws_iam_role" "hello_world_pod" {
  name = "hello-world-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.eks_oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.eks_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:hello-world:hello-world-sa"
        }
      }
    }]
  })

  tags = var.tags
}

# Attach example policy (S3 read-only)
resource "aws_iam_role_policy_attachment" "hello_world_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.hello_world_pod.name
}
