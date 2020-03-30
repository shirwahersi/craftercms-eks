output "endpoint" {
  description = "Elasticsearch endpoint"
  value       = aws_elasticsearch_domain.es.endpoint
}

output "es_kibana_endpoint" {
  description = "Domain-specific endpoint for kibana without https scheme."
  value       = aws_elasticsearch_domain.es.kibana_endpoint
}