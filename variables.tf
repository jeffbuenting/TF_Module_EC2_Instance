variable "num_instances" {
  description = "How many instances to create"
  type        = number
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

variable "kp_name" {
  description = "name of the keypair to use to encrypt/decrypt instance passwords"
  type        = string
}
variable "private_key" {
  description = "private key to decrypt the admin password"
  type        = string
}

variable "instance_name" {
  description = "base name of the instance"
  type        = string
}

variable "patchgroup" {
  description = "patch group the instance belongs"
  type        = string
}
