resource "aws_ecr_repository" "vmp_java" {
  name                 = "vmp-java"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "vmp-java"
    Environment = "dev"
  }
}

resource "aws_ecr_lifecycle_policy" "vmp_java_policy" {
  repository = aws_ecr_repository.vmp_java.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 14 days"
        selection = {
          tagStatus     = "untagged"
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 14
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
