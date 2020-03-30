# Copyright (C) 2007-2019 Crafter Software Corporation. All Rights Reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

variable "resource_name_prefix" {
  description = "The prefix used in the names of most infraestructure resources"
  default     = "craftercms"
  type        = string
}

variable "region" {
  description = "The AWS region where the infraestructure will be located"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the Elasticsearch domain will be created"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets where the Elasticsearch domain will be created"
  type        = list(string)
}

variable "create_security_group" {
  description = "If the security group used to access the DB cluster should be created automatically"
  default     = true
  type        = bool
}

variable "security_group_id" {
  description = "The ID of the security group used to access the Elasticsearch domain"
  default     = ""
  type        = string
}

variable "es_domain" {
  description = "The name of the Elasticsearch instance (which will be prepended with the resource_name_prefix)"
  type        = string
}

variable "es_version" {
  description = "Elasticsearch version"
  type        = string
}

variable "instance_type" {
  description = "The instance type of the Elasticsearch cluster nodes"
  type        = string
}

variable "instance_count" {
  description = "The instance count of the Elasticsearch cluster. Should be a multiple of the subnet_ids"
  default     = 2
  type        = number
}

variable "azs_count" {
  description = "The number of availability zones to use. Valid values are 1, 2 or 3"
  default     = 2
  type        = number
}

variable "ebs_volume_type" {
  description = "The type of EBS volumes attached to data nodes"
  default     = "gp2"
  type        = string
}

variable "ebs_volume_size" {
  description = "The size of EBS volumes attached to data nodes (in GB)"
  default     = 25
  type        = number
}