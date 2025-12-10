variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "demo-eks-cluster"
}

variable "node_group_desired_capacity" {
  type    = number
  default = 2
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "environment" {
  type    = string
  default = "dev"
}