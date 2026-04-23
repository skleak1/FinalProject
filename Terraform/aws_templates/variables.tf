variable "my_env" {
  description = "My environment variables"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string

  validation {
    condition     = startswith(var.ami_id, "ami-")
    error_message = "AMI ID must start with 'ami-'"
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition     = can(regex("^t[23]\\.", var.instance_type))
    error_message = "Instance type must be a t2 or t3 class family instance."
  }
}

variable "instance_count" {
  description = "This is instance count"
  type        = number
}

variable "root_volume_size" {
  description = "Size of EC2 root volume (GB)"
  type        = number
}

variable "root_volume_type" {
  description = "Type of EC2 root volume (gp2 or gp3)"
  type        = string
}
