resource "aws_ecr_repository" "this" {
  name = var.ecr_name

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name = var.ecr_name
  }
}

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid = "AllowPushPull"

    principals {
      type        = "AWS"
      identifiers = ["*"] # АБО вкажи ARN IAM ролі чи акаунту
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]

    effect = "Allow"
  }
}

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = data.aws_iam_policy_document.ecr_policy.json
}