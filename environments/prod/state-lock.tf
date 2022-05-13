resource "aws_dynamodb_table" "tfstate" {
  name         = "${local.env_prefix}-tfstate"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}
