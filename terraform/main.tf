terraform {
  required_version = ">= 1.0"
}

output "lab_name" {
  description = "Name of the CloudOps and SRE lab"
  value       = "cloudops-sre-lab"
}

output "environment" {
  description = "Current lab environment"
  value       = "local"
}
