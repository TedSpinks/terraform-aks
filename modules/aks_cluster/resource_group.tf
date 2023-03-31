resource "azurerm_resource_group" "this" {
  location = var.location
  name     = local.main_resource_group_name
  tags     = var.tags
}
