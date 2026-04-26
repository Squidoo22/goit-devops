output "bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "ARN of the S3 bucket"
}

output "bucket_url" {
  value       = aws_s3_bucket.terraform_state.bucket_domain_name
  description = "URL of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "Name of the DynamoDB table for state locking"
}

output "bucket_name" {
  description = "Name of the S3-bucket for states"
  value       = aws_s3_bucket.terraform_state.bucket
}
