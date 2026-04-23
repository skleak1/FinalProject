locals {
  ubuntu = "ami-0ec10929233384c7f" # Ubuntu 24.04 LTS (example)
}

locals {
  v1 = "gp3"
}

module "website-ec2" {
  source           = "./aws_templates"
  my_env           = "website"
  instance_type    = "t3.small"
  ami_id           = local.ubuntu
  root_volume_size = 8
  root_volume_type = local.v1
  instance_count   = 1
}

output "ec2_public_ip" {
  value = module.website-ec2.ec2_public_ip
}
