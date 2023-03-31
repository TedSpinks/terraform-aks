# The subnet must be in the same resource group as the VNet
resource "azurerm_subnet" "cluster_nodes" {
  name                 = local.cluster_nodes_subnet_name
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.aks_nodes_subnet_address_prefixes
}
