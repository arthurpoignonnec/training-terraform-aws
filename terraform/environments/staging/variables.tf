variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
}