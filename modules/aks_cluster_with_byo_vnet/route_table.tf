# A route table is required if Kubenet is used, and/or if Azure Gateway is used.
# No routes are required for Kubenet - the Control Plane will automatically add 
# routes for Kubenet any time a node pool scales.

resource "azurerm_route_table" "cluster_nodes" {
  count                         = (var.network_plugin == "kubenet") ? 1 : 0
  name                          = local.cluster_nodes_subnet_name
  location                      = var.location
  resource_group_name           = var.vnet_resource_group_name
  disable_bgp_route_propagation = false
}

resource "azurerm_subnet_route_table_association" "cluster_nodes" {
  count          = (var.network_plugin == "kubenet") ? 1 : 0
  subnet_id      = azurerm_subnet.cluster_nodes.id
  route_table_id = azurerm_route_table.cluster_nodes[0].id
}

# In order for AGIC to communicate with pods through Kubenet, it needs the Kubenet-created routes
resource "azurerm_subnet_route_table_association" "app_gateway" {
  count          = (var.network_plugin == "kubenet" && var.app_gateway_id != null) ? 1 : 0
  subnet_id      = var.app_gateway_subnet_id
  route_table_id = azurerm_route_table.cluster_nodes[0].id
}
