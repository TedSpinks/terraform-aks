resource "azurerm_resource_group" "this" {
  # If a resource group name was specified, use that. Otherwise, re-use the vnet name.
  name     = var.resource_group_name != "" ? var.resource_group_name : var.vnet_name
  location = var.location
  tags     = var.tags
}
