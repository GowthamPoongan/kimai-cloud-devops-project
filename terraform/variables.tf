# ✅ variables.tf — Reusable Variables

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID (x86, us-east-1)"
  default     = "ami-09e6f87a47903347c"
}

variable "instance_type" {
  description = "EC2 instance type (Free Tier eligible)"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Your AWS EC2 key pair name (no .pem)"
  default     = "My-Aws-Key" # 👈 Replace with your actual key pair name if different
}
