resource "aws_ecr_repository" "base" {
  name                 = local.realm_prefix
  image_tag_mutability = "MUTABLE"
  tags = {
    Name        = "${local.realm_prefix}-ecr"
  }
}
