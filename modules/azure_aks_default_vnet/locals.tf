# String interpolation reference: https://developer.hashicorp.com/terraform/language/expressions/strings#directives

locals {
  # Default resource group name matches the cluster name. If an override was provided, use that instead.
  main_resource_group_name = "%{if var.main_resource_group_name_override != ""}${var.main_resource_group_name_override}%{else}${var.cluster_name}%{endif}"

  # Default dns_prefix matches the cluster name (with DNS formatting). If an override was provided, use that instead.
  dns_formatted_cluster_name = lower(trim(replace(substr(var.cluster_name, 0, 54), "_", "-"), "-"))
  dns_prefix                 = "%{if var.dns_prefix_override != ""}${var.dns_prefix_override}%{else}${local.dns_formatted_cluster_name}%{endif}"
}
