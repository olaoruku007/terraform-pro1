output "address" {
  value       = aws_db_instance.pro1-db.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value       = aws_db_instance.pro1-db.port
  description = "The port the database is listening on"
}
