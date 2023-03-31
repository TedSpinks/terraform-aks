variable "resource_group_name" {
  type        = string
  description = "(Optional) Name of the Resource Group in which to deploy the hub resources. Defaults to the vnet_name."
  default     = ""
}

variable "vnet_name" {
  type        = string
  description = "Name of the VNet for AKS clusters"
}

variable "location" {
  type        = string
  description = "Region where the AKS VNet and related resources will reside"
}

variable "tags" {
  type        = map(any)
  description = "Any tags that should added to the AKS VNet and related resources"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "List of address range CIDRs in the VNet"
}
