terraform {
  required_version = ">= 0.12.0"

  required_providers {
    aws = ">= 2.31.0"
  }
}

data "aws_caller_identity" "current" {
}

data "aws_subnet" "subnet" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}


resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

#------------------------------------------------------------------------
# Elasticsearch Security Group
#------------------------------------------------------------------------
resource "aws_security_group" "es_sg" {
  count       = var.create_security_group ? 1 : 0
  name        = var.es_domain
  description = "Allows access to ${var.es_domain}"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = data.aws_subnet.subnet.*.cidr_block
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

#------------------------------------------------------------------------
# Elasticsearch Domain
#------------------------------------------------------------------------
resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.es_domain
  elasticsearch_version = var.es_version

  cluster_config {
    instance_type          = var.instance_type
    instance_count         = var.instance_count
    zone_awareness_enabled = var.azs_count > 1

    zone_awareness_config {
      availability_zone_count = var.azs_count
    }
  }

  vpc_options {
    subnet_ids         = slice(var.subnet_ids, 0, var.azs_count)
    security_group_ids = [var.create_security_group ? aws_security_group.es_sg[0].id : var.security_group_id]
  }

  ebs_options {
    ebs_enabled = true
    volume_type = var.ebs_volume_type
    volume_size = var.ebs_volume_size
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "es:*",
          "Principal": "*",
          "Effect": "Allow",
          "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.es_domain}/*"
      }
  ]
}
  CONFIG

  depends_on = [
    aws_iam_service_linked_role.es
  ]
}