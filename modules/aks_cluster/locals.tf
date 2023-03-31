locals {
  # Default resource group name matches the cluster name. If an override was provided, use that instead.
  main_resource_group_name = (var.main_resource_group_name_override != "") ? var.main_resource_group_name_override : var.cluster_name

  # Default dns_prefix matches the cluster name (with DNS formatting). If an override was provided, use that instead.
  dns_formatted_cluster_name = lower(trim(replace(substr(var.cluster_name, 0, 54), "_", "-"), "-"))
  dns_prefix                 = (var.dns_prefix_override != "") ? var.dns_prefix_override : local.dns_formatted_cluster_name

  # Convert a boolean var into an array with either 1 element or none. This array is used to enable or disable a dynamic block 
  # in cluster.tf. 1 element in the array enables the ingress_application_gateway block, 0 elements disables it.
  enable_app_gateway_dynamic_block = (var.enable_app_gateway) ? ["enable"] : []
}
