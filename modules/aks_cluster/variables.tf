# -------------------------------------- Placement --------------------------------------

variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "location" {
  type        = string
  description = "Region where the AKS resources will reside"
}

variable "zones" {
  type        = list(number)
  description = "The Availability Zones where the AKS resources will reside"
  default     = [1, 2, 3]
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to all the AKS resources"
}


# --------------------------------------- Network ---------------------------------------

variable "network_plugin" {
  type        = string
  description = "Which K8s network plugin to use: kubenet, azure, or azureoverlay. Cillium is coming soon."
  default     = "kubenet"
  validation {
    condition = (
      var.network_plugin == "kubenet" ||
      var.network_plugin == "azure" ||
      var.network_plugin == "azureoverlay"
    )
    error_message = "Must be one of: kubenet, azure, or azureoverlay"
  }
}

variable "app_gateway_enable" {
  type        = bool
  description = "Enable AGIC. If true, then either app_gateway_cidr or app_gateway_id is also required. Set to false when using Azure CNI Overlay."
  default     = true
}

variable "app_gateway_id" {
  description = "Object ID of a pre-created Application Gateway that this cluster should use for AGIC."
  default     = null
}

variable "app_gateway_cidr" {
  description = "The subnet CIDR to be used to create an Application Gateway for AGIC. AKS will auto-create along with the default VNet+Subnet. If you want to use BYO VNet, set this to null and use app_gateway_id instead."
  # Microsoft recommends a /24 subnet for AGIC. The default AKS VNet is 10.224.0.0/12, and its default 
  # node pool subnet is 10.224.0.0/16, so the next available /24 subnet after 10.224.0.0/16 but still 
  # within 10.224.0.0/12 is 10.225.0.0/24.
  default = "10.225.0.0/24"
}


# ------------------------------- Private K8s API Server --------------------------------

variable "private_cluster_enabled" {
  type        = bool
  description = "Only expose the K8s API server as a Private IP on the nodes' subnet"
  default     = false
}


# ---------------------------------------- RBAC -----------------------------------------

variable "azure_rbac_admin_group_object_ids" {
  type        = list(string)
  description = "(Optional) A list of AAD Group Object IDs that should have Admin access to the Cluster"
  default     = []
}

variable "azure_rbac_reader_group_object_ids" {
  type        = list(string)
  description = "(Optional) A list of AAD Group Object IDs that should have Read-Only access to the Cluster"
  default     = []
}


# ------------------------------------- Node Pools --------------------------------------

variable "ssh_public_key" {
  type        = string
  description = "SSH public key to inject into all K8s nodes"
  sensitive   = true
}

variable "system_node_pool_vm_size" {
  type        = string
  description = "VM size of the K8s system nodes (aka control plane)"
  default     = "Standard_D2_v4"
}

variable "system_node_pool_count" {
  type        = number
  description = "Number of K8s system nodes (aka control plane)"
  default     = 3
}

variable "user_node_pool_vm_size" {
  type        = string
  description = "VM size of the K8s user nodes (aka workers)"
  default     = "Standard_D2_v2"
}

variable "user_node_pool_autoscaler" {
  type        = bool
  description = "Whether or not to enable autoscaler on the user node pool"
  default     = false
}

variable "user_node_pool_autoscaler_min_nodes" {
  type        = number
  description = "Autoscaler won't scale down below this number of nodes"
  default     = null
}

variable "user_node_pool_autoscaler_max_nodes" {
  type        = number
  description = "Autoscaler won't scale up beyond this number of nodes"
  default     = null
}

variable "user_node_pool_count" {
  type        = number
  description = "Number of K8s user nodes (aka workers). When using autoscaler, this will be the initial number of nodes (usually matches user_node_pool_autoscaler_min_nodes)"
  default     = 1
}


# ------------------------------------ Auto-Upgrade -------------------------------------

variable "automatic_upgrade_channel" {
  type        = string
  description = "The upgrade channel for this AKS cluster: rapid, stable, patch, or node-image. To fully automate upgrades, choose rapid or stable."
  default     = "stable"
}

variable "maintenance_allowed_windows" {
  description = "List of weekly maintenance windows for auto-upgrades. For example, Tues+Thurs at 9am+10am would be: [ {day = \"Tuesday\", hours = [9,10]}, {day = \"Thursday\", hours = [9,10]} ]"
  type = list(object({
    day   = string
    hours = list(number)
  }))
  # default = [ {day = "Tuesday", hours = [9,10]}, {day = "Thursday", hours = [9,10]} ]
}

variable "maintenance_not_allowed_windows" {
  description = "List of RFC3339 date+time strings that are exceptions to maintenance_allowed_windows. For example, May 1, 2024, 7:20 AM UTC would be: 2024-05-01 07:20:00.00Z"
  type = list(object({
    begin_date_time = string
    end_date_time   = string
  }))
  default = []
}


# ---------------------------------- Optional Settings ----------------------------------

variable "sku_tier" {
  type        = string
  description = "AKS SKU: Free or Standard. Free = no SLAs."
  default     = "Standard"
}

variable "main_resource_group_name_override" {
  type        = string
  description = "(Optional) Override the default resource group name for the AKS and monitoring resources. Uses cluster_name by default."
  default     = ""
}

variable "dns_prefix_override" {
  type        = string
  description = "(Optional) Override the default DNS prefix for the K8s API FQDN. Uses cluster_name by default."
  default     = ""
  # Basic DNS validation to prevent errors during apply
  validation {
    condition = (length(var.dns_prefix_override) <= 54 &&
      var.dns_prefix_override == lower((trim(replace(var.dns_prefix_override, "_", "-"), "-")))
    )
    error_message = "Must be between 1 and 54 characters long, contain only alphanumerics and hyphens, and start and end with alphanumeric."
  }
}

