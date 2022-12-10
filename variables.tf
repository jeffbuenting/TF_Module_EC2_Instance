variable "num_instances" {
  description = "How many instances to create"
  type        = num
  default     = 1
}

variable "ami" {
  description = "AWS AMI to use"
  type        = string
  default     = "ami-06371c9f2ad704460" # Windows AMI
}

variable "instance_type" {
  description = "EC2 instance type to use."
  type        = string
  default     = "t2.micro"
}
