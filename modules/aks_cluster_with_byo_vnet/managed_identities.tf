# The AKS cluster's Control Plane Managed Identity.
# A "User-Assigned" (i.e. created + assigned roles by TF instead of by AKS) Managed Identity
# is requried to BYO route table, which we need for using Kubenet with BYO VNet.
# Reference: https://learn.microsoft.com/en-us/azure/aks/use-managed-identity
resource "azurerm_user_assigned_identity" "this" {
  count               = (var.network_plugin == "kubenet") ? 1 : 0
  location            = azurerm_resource_group.this.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

# The AKS cluster's Control Plane Managed Identity needs the ability to manage the subnet of its node pools.
resource "azurerm_role_assignment" "subnet" {
  role_definition_name = "Network Contributor"
  scope                = azurerm_subnet.cluster_nodes.id
  # For Kubenet, target the User-Managed id we created; 
  # For Azure CNI and Azure CNI Overlay, target the System-Assigned id that AKS creates 
  principal_id = (var.network_plugin == "kubenet") ? azurerm_user_assigned_identity.this[0].principal_id : azurerm_kubernetes_cluster.this.identity[0].principal_id
}

# The AKS cluster's Control Plane Managed Identity (Kubenet) needs the ability to manage the route table for Kubenet.
resource "azurerm_role_assignment" "route_table" {
  count                = (var.network_plugin == "kubenet") ? 1 : 0
  role_definition_name = "Network Contributor"
  scope                = azurerm_route_table.cluster_nodes[0].id
  principal_id         = azurerm_user_assigned_identity.this[0].principal_id
}

# The AKS cluster's AGIC Managed Identity needs the ability to manage the App Gateway.
# When you BYO a shared App Gateway instead of letting AKS create it, we need to add
# this permission after AKS creates a Managed Identity for talking to the App Gateway.
resource "azurerm_role_assignment" "app_gateway" {
  count                = (var.app_gateway_enable != false) ? 1 : 0
  role_definition_name = "Contributor"
  scope                = var.app_gateway_id
  principal_id         = azurerm_kubernetes_cluster.this.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

# The AKS cluster's AGIC Managed Identity needs to read the App Gateway's resource group.
# When you BYO a shared App Gateway instead of letting AKS create it, we need to add
# this permission after AKS creates a Managed Identity for talking to the App Gateway.
resource "azurerm_role_assignment" "agw_resource_group" {
  count                = (var.app_gateway_enable != false) ? 1 : 0
  role_definition_name = "Reader"
  scope                = var.vnet_resource_group_id
  principal_id         = azurerm_kubernetes_cluster.this.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
