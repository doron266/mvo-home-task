terraform {
  # Run init/plan/apply with "backend" commented-out (ueses local backend) to provision Resources (Bucket, Table)
  # Then uncomment "backend" and run init, apply after Resources have been created (uses AWS)
  backend "s3" {
    bucket         = "dw-tf-state-212343107"
    key            = "tf-infra/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_version = ">=0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

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
  target_instance_ids = {
  for idx, id in module.compute[0].instance_ids :
  idx => id
  }
}

output "module_alb_dns_name" {
  value       = var.use_modules ? module.alb[0].alb_dns_name : null
  description = "DNS name for the ALB created by the module-based stack"
}
