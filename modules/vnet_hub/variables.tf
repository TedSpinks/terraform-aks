variable "resource_group_name" {
  type        = string
  description = "(Optional) Name of the Resource Group in which to deploy the hub resources. Defaults to the vnet_name."
  default     = ""
}

variable "location" {
  type        = string
  description = "Region where the hub resources will reside"
}

variable "tags" {
  type        = map(any)
  description = "Any tags that should added to the hub resources"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network for hub resources"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "List of address range CIDRs in the Virtual Network"
}

variable "azure_firewall_subnet_address_prefixes" {
  type        = list(string)
  description = "List of address range CIDRs for the Azure Firewall. Microsoft recommends a /24. Example: [\"10.223.0.0/24\"]"
}

variable "azure_firewall_pip_name" {
  type        = string
  description = "Name of the Public IP for the Azure Firewall"
  default     = "firewall"
}

variable "azure_firewall_name" {
  type        = string
  description = "Name of the Azure Firewall"
  default     = "firewall"
}

variable "azure_bastion_subnet_address_prefixes" {
  type        = list(string)
  description = "List of address range CIDRs for the Azure Bastion Service. Example: [\"10.223.1.0/26\"]"
}

variable "azure_bastion_pip_name" {
  type        = string
  description = "Name of the Public IP for the Azure Bastion Service"
  default     = "bastion"
}

variable "azure_bastion_host_name" {
  type        = string
  description = "Name of the Azure Bastion Host"
  default     = "bastion"
}

