output "realm_prefix" {
  value = local.realm_prefix
}

output "company" {
  value = var.company
}

output "realm" {
  value = var.realm
}

output "json_bucket_id" {
  value = aws_s3_bucket.json.id
}

output "json_bucket_arn" {
  value = aws_s3_bucket.json.arn
}

output "json_object_id" {
  value = aws_s3_object.json.id
}
