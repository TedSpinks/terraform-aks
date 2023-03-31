variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group in which to deploy the App Gateway."
}

variable "location" {
  type        = string
  description = "Region in which to deploy the App Gateway. Must match the VNet's region."
}

variable "vnet_name" {
  type        = string
  description = "Name of the VNet in which to deploy the App Gateway."
}

variable "tags" {
  type        = map(any)
  description = "Any tags that should added to the App Gateway."
}

variable "sku" {
  type        = string
  description = "The App Gateway SKU. For AKS use either Standard_v2 or WAF_v2."
  default     = "Standard_v2"
  validation {
    condition     = var.sku == "Standard_v2" || var.sku == "WAF_v2"
    error_message = "Must be either Standard_v2 or WAF_v2."
  }
}

variable "app_gateway_subnet_name" {
  type        = string
  description = "Name of the Application Gateway's subnet"
  default     = "application-gateway"
}

variable "app_gateway_subnet_address_prefixes" {
  type        = list(string)
  description = "List of address range CIDRs for the Application Gateway that will be shared among AKS clusters' AGICs. Microsoft recommends a /24 subnet. Example: [\"10.89.0.0/24\"]"
}

variable "app_gateway_name" {
  type        = string
  description = "Name of the Application Gateway"
  default     = "aks"
}

variable "app_gateway_pip_name" {
  type        = string
  description = "Name of the Public IP for the Application Gateway"
  default     = "agw-aks"
}
