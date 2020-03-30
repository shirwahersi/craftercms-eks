terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.11"
  region  = var.region
}


locals {
  cluster_name      = "${var.environment}-${var.resource_name_prefix}-eks-cluster"
}


#------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------

module "vpc" {
  source                      = "terraform-aws-modules/vpc/aws"
  version                     = "~> 2.0"
  name                        = "${var.environment}-${var.resource_name_prefix}-vpc"
  cidr                        = var.vpc_cidr
  azs                         = var.azs
  private_subnets             = var.private_subnets_cidrs
  public_subnets              = var.public_subnets_cidrs
  database_subnets            = var.db_subnets_cidrs
  enable_nat_gateway          = true
  single_nat_gateway          = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                                                           = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                                                  = "1"
  }
}

#------------------------------------------------------------------------
# RDS
#------------------------------------------------------------------------

# DB Secret

data "aws_secretsmanager_secret" "db_secret" {
  name = var.db-credentials
}
data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

module "rds_sg" {
  source                      = "terraform-aws-modules/security-group/aws//modules/mysql"

  name                        = "rds security group"
  description                 = "Security group for restricting access to RDS"
  vpc_id                      = module.vpc.vpc_id

  ingress_cidr_blocks         = module.vpc.private_subnets_cidr_blocks
}

module "rds" {
  source                      = "terraform-aws-modules/rds/aws"
  version                     = "~> 2.0"
  identifier                  = "${var.environment}-${var.resource_name_prefix}-db"

  engine                      = var.rds-engine
  engine_version              = var.rds-engine-version
  instance_class              = var.rds-instance-class
  allocated_storage           = var.rds-allocated-storage
  skip_final_snapshot         = "true"

  name                        = var.db-name
  username                    = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["db_user"]
  password                    = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["db_password"]
  port                        = var.rds-port

  vpc_security_group_ids      = ["${module.rds_sg.this_security_group_id}"]
  subnet_ids                  = module.vpc.database_subnets

  maintenance_window          = "Mon:00:00-Mon:03:00"
  backup_window               = "03:00-06:00"

  # DB parameter group
  family = var.rds-family

  parameters = [
    {
      name = "innodb_large_prefix"
      value = "true"
    },
    {
      name = "innodb_file_format"
      value = "Barracuda"
    }
  ]

  # DB option group
  major_engine_version = var.rds-major-engine-version

  tags = {
    Environment               = var.environment
  }
}

#------------------------------------------------------------------------
# EKS
#------------------------------------------------------------------------

data "aws_eks_cluster" "cluster" {
  name                        = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name                        = module.eks.cluster_id
}

provider "kubernetes" {
  host                        = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate      = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                       = data.aws_eks_cluster_auth.cluster.token
  load_config_file            = false
//  version                     = "~> 1.9"
}

module "eks" {
  source                      = "terraform-aws-modules/eks/aws"
  version                     = "v10.0.0"
  cluster_name                = local.cluster_name
  cluster_version             = var.cluster_version
  subnets                     = module.vpc.private_subnets
  vpc_id                      = module.vpc.vpc_id
  enable_irsa                 = true
  write_kubeconfig            = false
  cluster_enabled_log_types   = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  worker_groups = [
    {
      instance_type           = var.worker_instance_type
      asg_desired_capacity    = var.worker_asg_desired_capacity
      asg_max_size            = var.worker_asg_min_size
      asg_max_size            = var.worker_asg_max_size
      key_name                = var.worker_instance_key_name
      tags = [{
        key                   = "environment"
        value                 = var.environment
        propagate_at_launch   = true
      }]
    }
  ]

  tags = {
    environment               = var.environment
  }
}

// ALBIngressController IAM Role
module "ALBIngressControllerIAMRole" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.0"
  create_role                   = true
  role_name                     = "ALBIngressControllerIAMRole"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.ALBIngressControllerIAMPolicy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:alb-ingress-controller-aws-alb-ingress-controller"]
}

resource "aws_iam_policy" "ALBIngressControllerIAMPolicy" {
  name_prefix = "ALBIngessControllerIAMRole"
  description = "ALB Ingress Controller IAM Policy"
  policy      = file("templates/iam/AlbIngressControllerIAMPolicy.json")
}

// external-dns IAM Role
module "ExternalDnsIAMRole" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.0"
  create_role                   = true
  role_name                     = "ExternalDnsIAMRole"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.ExternalDnsIAMPolicy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:external-dns"]
}

resource "aws_iam_policy" "ExternalDnsIAMPolicy" {
  name_prefix = "ExternalDnsIAMRole"
  description = "external-dns Controller IAM Policy"
  policy      = file("templates/iam/ExternalDnsIAMPolicy.json")
}


#------------------------------------------------------------------------
# Elasticsearch
#------------------------------------------------------------------------

module "es" {
  source               = "./modules/aws-elasticsearch"
  es_domain            = "${var.environment}-${var.resource_name_prefix}-es"
  es_version           = var.es_version
  instance_type        = var.es_instance_type
  region               = var.region
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnets
}