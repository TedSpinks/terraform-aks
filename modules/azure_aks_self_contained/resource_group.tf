resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = local.resource_group_main_name
  tags = var.tags
}
