locals {
  company      = data.terraform_remote_state.common.outputs.company
  realm        = data.terraform_remote_state.common.outputs.realm
  realm_prefix = data.terraform_remote_state.common.outputs.realm_prefix
  env_prefix   = "${local.realm_prefix}-${var.environment}"
  object_arn   = "${data.terraform_remote_state.common.outputs.json_bucket_arn}/${data.terraform_remote_state.common.outputs.json_object_id}"
  app_image    = "${data.terraform_remote_state.global_ecr.outputs.base_ecr_url}:latest"
  account_id   = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}
