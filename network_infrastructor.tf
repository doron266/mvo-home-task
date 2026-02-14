terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.24.1"
    }
  }
  required_version = ">= 0.15"
}

provider "aws" {
  region  = var.region
  profile = "default"
}

#############################
# Get list of available AZs #
#############################
data "aws_availability_zones" "available_zones" {
  state = "available"
}

##################
# Create the VPC #
##################
resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
}

###############################
# Create the internet gateway #
###############################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id
}

#############################
# Create the public subnets #
#############################
resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.app_vpc.id

  count             = 2
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  map_public_ip_on_launch = true
  tags = {
    Tier = "public"
  }
}

##############################
# Create the private subnets #
##############################
resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.app_vpc.id

  count             = var.private_subnets_conf
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 2 + count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  map_public_ip_on_launch = false # This and routing to NAT makes the subnet private
}

#################################
# Create the public route table #
#################################
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

######################################################
# Assign the public route table to the public subnet #
######################################################
resource "aws_route_table_association" "public_rt_asso" {
  count          = 2
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

##################################################
# Set default route table as private route table #
##################################################
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  count = var.private_subnets_conf
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gate_way[count.index].id
  }
}

########################################################
# Assign the private route table to the private subnet #
########################################################
resource "aws_route_table_association" "private_rt_asso" {
  count          = var.private_subnets_conf
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_route_table[count.index].id
}

###############################
# Create EIP for NAT Gateways #
###############################
resource "aws_eip" "eip_nat_gw" {
  count = var.private_subnets_conf
}

################################################################################
# Create NAT Gateways in each public subnets
################################################################################
resource "aws_nat_gateway" "nat_gate_way" {
  count         = var.private_subnets_conf
  allocation_id = aws_eip.eip_nat_gw[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
}
