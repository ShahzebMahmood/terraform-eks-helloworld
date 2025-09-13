variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

resource "aws_ecr_repository" "hello_world" {
  name                 = "hello-world"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}
