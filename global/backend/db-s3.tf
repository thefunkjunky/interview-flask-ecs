resource "aws_kms_key" "json" {
  description = "Used for encryption of json bucket"
}


resource "aws_s3_bucket" "json" {
  bucket = "${local.realm_prefix}-json"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.json.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Name = "${var.company} ${var.realm} json bucket"
  }
}

# JSON object will be copied into above bucket
resource "aws_s3_object" "json" {
  key                    = "foobar.json"
  bucket                 = aws_s3_bucket.json.id
  source                 = "files/foobar.json"
}
