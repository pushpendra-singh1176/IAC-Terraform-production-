
variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "eks_vpc_id" {
  description = "VPC ID for EKS"
  type        = string
}

variable "eks_subnet_ids" {
  description = "Subnets for EKS"
  type        = list(string)
}