resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${local.env_prefix}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "${local.env_prefix}-task-execution-role"
    Environment = var.environment
  }
}

resource "aws_iam_role" "ecsTaskRole" {
  name               = "${local.env_prefix}-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "${local.env_prefix}-task-role"
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "read_s3" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = ["s3:ListBucket"]

    resources = [
      data.terraform_remote_state.common.outputs.json_bucket_arn,
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    resources = [
      local.object_arn,
    ]
  }
}

resource "aws_iam_policy" "read_s3" {
  name        = "read_s3"
  path        = "/"
  description = "IAM policy to read json s3 bucket object"

  policy = data.aws_iam_policy_document.read_s3.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "read_s3" {
  role       = aws_iam_role.ecsTaskRole.name
  policy_arn = aws_iam_policy.read_s3.arn
}
