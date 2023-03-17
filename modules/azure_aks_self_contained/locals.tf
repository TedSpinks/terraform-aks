locals {
  # Default resource group name matches the cluster name. If an override was provided, use that instead.
  resource_group_main_name = "%{ if var.resource_group_main_name_override != "" }${var.resource_group_main_name_override}%{ else }${var.cluster_name}%{ endif }"

}
