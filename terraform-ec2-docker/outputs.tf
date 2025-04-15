output "instance_public_ip" {
  value = aws_instance.spring_app.public_ip
}
output "db_endpoint" {
  value = aws_db_instance.spring_db.endpoint
}
output "ecr_repo_url" {
  value = aws_ecr_repository.vmp_java.repository_url
}
