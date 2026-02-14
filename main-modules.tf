module "network" {
  count  = var.use_modules ? 1 : 0
  source = "./modules/network"

  vpc_cidr_block       = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  private_subnets_conf = var.private_subnets_conf
}

module "compute" {
  count  = var.use_modules ? 1 : 0
  source = "./modules/compute"

  vpc_id             = module.network[0].vpc_id
  private_subnet_ids = module.network[0].private_subnet_ids
  instance_type      = var.instance_type
  ec2_count          = var.ec2_count
  key_pair           = var.key_pair
  ami_version        = var.ami_version
  sg_ingress_rules   = var.sg_ingress_rules
}

module "alb" {
  count  = var.use_modules ? 1 : 0
  source = "./modules/alb"

  vpc_id              = module.network[0].vpc_id
  public_subnet_ids   = module.network[0].public_subnet_ids
  target_instance_ids = module.compute[0].instance_ids
}

output "module_alb_dns_name" {
  value       = var.use_modules ? module.alb[0].alb_dns_name : null
  description = "DNS name for the ALB created by the module-based stack"
}
