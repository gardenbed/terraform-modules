variable "bastion_key_name" {
  type = string
}

module "fabric" {
  source = "../../aws/fabric"

  name               = var.name
  region             = var.region
  az_count           = 3
  bastion_public_key = "${path.module}/${var.bastion_key_name}.pub"
  metadata           = module.metadata.common
}
