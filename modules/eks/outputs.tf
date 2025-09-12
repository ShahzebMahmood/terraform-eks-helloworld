output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority" {
  description = "EKS cluster certificate authority"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "kubeconfig" {
  description = "Kubeconfig content for local access"
  value = yamlencode({
    apiVersion = "v1"
    clusters = [
      {
        cluster = {
          server                   = aws_eks_cluster.this.endpoint
          "certificate-authority-data" = aws_eks_cluster.this.certificate_authority[0].data
        }
        name = aws_eks_cluster.this.name
      }
    ]
    contexts = [
      {
        context = {
          cluster = aws_eks_cluster.this.name
          user    = aws_eks_cluster.this.name
        }
        name = aws_eks_cluster.this.name
      }
    ]
    current-context = aws_eks_cluster.this.name
    kind            = "Config"
    users = [
      {
        name = aws_eks_cluster.this.name
        user = {
          exec = {
            apiVersion = "client.authentication.k8s.io/v1beta1"
            command    = "aws"
            args       = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name]
          }
        }
      }
    ]
  })
}
