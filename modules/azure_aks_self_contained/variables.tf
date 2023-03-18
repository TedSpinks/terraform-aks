# -------------------------------------- Placement --------------------------------------

variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "location" {
  type        = string
  description = "Region where the AKS resources will reside"
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should added to the AKS resources"
}


# ------------------------------------ Node Pools -------------------------------------

variable "ssh_public_key" {
  description = "SSH public key to inject into all K8s nodes"
  sensitive   = true
}

variable "system_node_pool_count" {
  description = "Number of K8s system nodes (aka control plane)"
  default     = 3
}

variable "system_node_pool_vm_size" {
  description = "VM size of the K8s system nodes (aka control plane)"
  default     = "Standard_D2_v2"
}

variable "user_node_pool_count" {
  description = "Number of K8s user nodes (aka workers)"
  default     = 3
}

variable "user_node_pool_vm_size" {
  description = "VM size of the K8s user nodes (aka workers)"
  default     = "Standard_D2_v2"
}


# ------------------------------- Misc Optional Settings ------------------------------

variable "network_plugin" {
  type        = string
  description = "Which K8s network plugin to use: kubenet or azure. Cillium is coming soon."
  default     = "azure"
}

variable "sku_tier" {
  type        = string
  description = "AKS SKU: Free, Paid, or Standard. Free = no SLAs."
  default     = "Standard"
}

variable "main_resource_group_name_override" {
  type        = string
  description = "Optional. Override the default resource group name for the AKS and monitoring resources. Uses cluster_name by default."
  default     = ""
}

variable "dns_prefix_override" {
  description = "Optional. Override the default DNS prefix for the K8s API FQDN. Uses cluster_name by default."
  default     = ""
  # Basic validation to prevent errors during apply
  validation {
    condition = (length(var.dns_prefix_override) <= 54 &&
      var.dns_prefix_override == lower((trim(replace(var.dns_prefix_override, "_", "-"), "-")))
    )
    error_message = "Must be between 1 and 54 characters long, contain only alphanumerics and hyphens, and start and end with alphanumeric."
  }
}
