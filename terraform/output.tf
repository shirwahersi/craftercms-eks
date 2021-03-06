output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks.kubeconfig
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.config_map_aws_auth
}

output "rds_endpoint" {
  description = "The address of the RDS instance"
  value       = module.rds.this_db_instance_address
}

output "es_endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests."
  value       = module.es.endpoint
}

output "es_kibana_endpoint" {
  description = "Domain-specific endpoint for kibana without https scheme."
  value       = module.es.es_kibana_endpoint
}
