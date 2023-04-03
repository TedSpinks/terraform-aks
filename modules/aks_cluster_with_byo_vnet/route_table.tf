# A route table is required if Kubenet is used, and/or if Azure Gateway is used.
# No routes are required for Kubenet - the Control Plane will automatically add 
# routes for Kubenet any time a node pool scales.

locals {
  route_table_required = (var.network_plugin == "kubenet" || var.outbound_type == "userDefinedRouting")
}

# Create Route Table
resource "azurerm_route_table" "cluster_nodes" {
  count                         = local.route_table_required ? 1 : 0
  name                          = local.cluster_nodes_subnet_name
  location                      = var.location
  resource_group_name           = var.vnet_resource_group_name
  disable_bgp_route_propagation = false
}

# Add Azure Firewall routes
# Reference: https://learn.microsoft.com/en-us/azure/aks/limit-egress-traffic#create-a-udr-with-a-hop-to-azure-firewall
resource "azurerm_route" "aks_egress_fwrn" {
  count                  = local.route_table_required ? 1 : 0
  name                   = "aks-egress-fwrn"
  resource_group_name    = var.vnet_resource_group_name
  route_table_name       = azurerm_route_table.cluster_nodes[0].name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.azure_firewall_private_ip
}
resource "azurerm_route" "aks_egress_fwinternet" {
  count               = local.route_table_required ? 1 : 0
  name                = "aks-egress-fwinternet"
  resource_group_name = var.vnet_resource_group_name
  route_table_name    = azurerm_route_table.cluster_nodes[0].name
  address_prefix      = "${var.azure_firewall_pip_address}/32"
  next_hop_type       = "Internet"
}

# Associate route table with AKS cluster's node subnet
resource "azurerm_subnet_route_table_association" "cluster_nodes" {
  count          = local.route_table_required ? 1 : 0
  subnet_id      = azurerm_subnet.cluster_nodes.id
  route_table_id = azurerm_route_table.cluster_nodes[0].id
}

# In order for AGIC to communicate with pods through Kubenet, it needs the Kubenet-created routes
resource "azurerm_subnet_route_table_association" "app_gateway" {
  count          = (var.network_plugin == "kubenet" && var.app_gateway_enable != false) ? 1 : 0
  subnet_id      = var.app_gateway_subnet_id
  route_table_id = azurerm_route_table.cluster_nodes[0].id
}
