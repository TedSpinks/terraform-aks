locals {
  # Set plugin settings for Azure CNI Overlay which differs from Kubenet and Azure CNI in that it requires 2 settings
  network_plugin      = (var.network_plugin == "azureoverlay") ? "azure" : var.network_plugin
  network_plugin_mode = (var.network_plugin == "azureoverlay") ? "Overlay" : null

  # Convert a boolean var into an array with either 1 element or none. This array is used to enable or disable a dynamic block 
  # in cluster.tf. 1 element in the array enables the "ingress_application_gateway" dynamic block, 0 elements disables it.
  app_gateway_enable_dynamic_block = (var.app_gateway_enable) ? ["enable"] : []

  # Default resource group name matches the cluster name. If an override was provided, use that instead.
  main_resource_group_name = (var.main_resource_group_name_override != "") ? var.main_resource_group_name_override : var.cluster_name

  # Default dns_prefix matches the cluster name (with DNS formatting). If an override was provided, use that instead.
  dns_formatted_cluster_name = lower(trim(replace(substr(var.cluster_name, 0, 54), "_", "-"), "-"))
  dns_prefix                 = (var.dns_prefix_override != "") ? var.dns_prefix_override : local.dns_formatted_cluster_name
}
