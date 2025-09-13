variable "vpc_id" {
  description = "VPC ID where ECS will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID (must be public) to deploy ECS tasks"
  type        = string
}
