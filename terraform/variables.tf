variable "resource_name_prefix" {
  description = "The prefix used in the names of most infraestructure resources"
  default     = "craftercms"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  default     = "staging"
  type        = string
}

// VPC

variable "region" {
  description = "The AWS region where the infraestructure will be located"
  default     = "eu-west-2"
  type        = string
}

variable "azs" {
  description = "The availability zones where the infraestructure will be located"
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  type        = list(string)
}

variable "vpc_cidr" {
  description = "The CIDR block for the cloud VPC"
  default     = "172.16.0.0/16"
  type        = string
}

variable "private_subnets_cidrs" {
  description = "The CIDRs of private subnets of the cloud VPC. The default values allow 4094 hosts per subnet"
  default     = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  type        = list(string)
}

variable "public_subnets_cidrs" {
  description = "The CIDRs of public subnets of the cloud VPC. The default values allow 4094 hosts per subnet"
  default     = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  type        = list(string)
}

variable "db_subnets_cidrs" {
  description = "The CIDRs of public subnets of the cloud VPC. The default values allow 4094 hosts per subnet"
  default     = ["172.16.7.0/24", "172.16.8.0/24", "172.16.9.0/24"]
  type        = list(string)
}


// RDS

variable "db-name" {
  default     = "crafter"
  type        = string
  description = "RDS Database name"
}

variable "db-credentials" {
  default     = "/crafter/test/credentials"
  type        = string
  description = "RDS secret mamanager credentials"
}

variable "rds-engine" {
  default     = "mysql"
  type        = string
  description = "The name of the database engine that you want to use for this DB instance. "
}

variable "rds-engine-version" {
  default     = "5.6"
  type        = string
  description = "The version number of the database engine to use."
}

variable "rds-instance-class" {
  default     = "db.t2.micro"
  type        = string
  description = "The compute and memory capacity of the DB instance, for example, db.m4.large."
}

variable "rds-allocated-storage" {
  default     = "20"
  type        = string
  description = "The amount of storage (in gigabytes) to be initially allocated for the database instance."
}

variable "rds-port" {
  default     = "3306"
  type        = string
  description = "The port on which the DB accepts connections"
}

variable "rds-family" {
  default     = "mysql5.6"
  type        = string
  description = "The family of the DB parameter group"
}

variable "rds-major-engine-version" {
  default     = "5.6"
  type        = string
  description = "Specifies the major version of the engine that this option group should be associated with"
}

// EKS

variable "cluster-name" {
  default     = "craftercms-eks-test"
  type        = string
  description = "The name of your EKS Cluster"
}

variable "cluster_version" {
  default     = "1.15"
  type        = string
  description = "Kubernetes version to use for the EKS cluster.	"
}

variable "worker_instance_type" {
  default     = "t2.large"
  type        = string
  description = "Worker EC2 Instance type"
}

variable "worker_asg_max_size" {
  default     = "2"
  type        = string
  description = "Worker ASG Max size"
}

variable "worker_asg_min_size" {
  default     = "1"
  type        = string
  description = "Worker ASG Min size"
}

variable "worker_asg_desired_capacity" {
  default     = "1"
  type        = string
  description = "Worker ASG Desired size"
}

variable "worker_instance_key_name" {
  default     = "shirwalab"
  type        = string
  description = "EC2 ssh key pair name"
}

// Elasticsearch
variable "es_domain" {
  default     = "crafter-es"
  type        = string
  description = "Name of the ES domain"
}

variable "es_version" {
  default     = "6.8"
  type        = string
  description = "The version of Elasticsearch to deploy"
}

variable "es_instance_type" {
  default     = "t2.small.elasticsearch"
  type        = string
  description = "(Optional) Instance type of data nodes in the cluster."
}