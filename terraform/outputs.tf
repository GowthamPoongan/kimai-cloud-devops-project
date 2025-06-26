output "bastion_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "kimai_private_ip" {
  description = "Private IP of the Kimai Server"
  value       = aws_instance.kimai.private_ip
}

output "ssh_hint" {
  description = "Use this to connect to Bastion"
  value       = "ssh -i My-Aws-Key.pem ec2-user@${aws_instance.bastion.public_ip}"
}

output "kimai_url" {
  description = "Kimai App URL via SSH tunnel"
  value       = "http://localhost:8001"
}

output "jenkins_url" {
  description = "Jenkins URL via SSH tunnel"
  value       = "http://localhost:8080"
}
