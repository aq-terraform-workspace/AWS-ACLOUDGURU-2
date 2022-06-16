module "ecr_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["ecr"]
  context    = module.base_label.context
}

module "ecr" {
  source  = "lgallard/ecr/aws"
  version = "0.3.2"

  name                 = module.ecr_label.id
  scan_on_push         = var.scan_on_push
  image_tag_mutability = var.image_tag_mutability
  timeouts_delete      = var.timeouts_delete

  policy = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "repo policy",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:BatchDeleteImage",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy"
        ]
      }
    ]
  }
  EOF

  lifecycle_policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Expire untagged images older than 14 days",
        "selection": {
          "tagStatus": "untagged",
          "countType": "sinceImagePushed",
          "countUnit": "days",
          "countNumber": 14
        },
        "action": {
          "type": "expire"
        }
      },
      {
        "rulePriority": 2,
        "description": "Keep last 30 dev images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["dev"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOF
  tags             = module.ecr_label.tags
}