variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should added to the AKS resources"
}

variable "location" {
  type        = string
  description = "Region where the AKS resources will reside"
}

variable "resource_group_main_name_override" {
  type        = string
  description = "Optional. Override the default resource group name for the AKS and monitoring resources. Uses cluster_name by default."
  default = ""
}

variable "agent_count" {
  default = 3
}

variable "dns_prefix" {
  # default = "k8stest"
}

variable "log_analytics_workspace_name" {
  default = "testLogAnalyticsWorkspaceName"
}

variable "resource_group_name_prefix" {
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "ssh_public_key" {
  description = "SSH public key to inject into all K8s nodes"
  sensitive   = true
}
