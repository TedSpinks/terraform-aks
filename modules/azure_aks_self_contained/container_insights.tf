resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "this" {
  location = var.location
  # The WorkSpace name has to be unique across the whole of azure;
  # not just the current subscription/tenant.
  name                = "${var.cluster_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  resource_group_name = azurerm_resource_group.this.name
  # Sku explanation: # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace#sku
  sku  = "PerGB2018" # aka Pay-as-you-go
  tags = var.tags
}

resource "azurerm_log_analytics_solution" "this" {
  location              = azurerm_log_analytics_workspace.this.location
  resource_group_name   = azurerm_resource_group.this.name
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.this.name
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
  tags = var.tags
}
