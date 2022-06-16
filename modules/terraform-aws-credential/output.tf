output "value" {
  value     = aws_ssm_parameter.credential.value
  sensitive = true
}

output "name" {
  value = aws_ssm_parameter.credential.name
}
