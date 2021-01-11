variable "name" {
  description = "User name for the database."
  default     = "eks-demo"
}

variable "password" {
  description = "Password for the database"
  default     = "prod"
}

variable "region" {
  default = "eu-west-1"
}

