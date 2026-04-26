output "db_endpoint" {
    description = "RDS endpoint for DB connection"
    value = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].endpoint
}
