locals {
  aks_cluster_name = "aks-example-2"
}

# Hub VNet (and RG) with Azure Firewall for controlling egress, and Azure Bastion
module "vnet_hub" {
  source                                 = "../../modules/vnet_hub"
  resource_group_name                    = "hub-aks-services"
  vnet_name                              = "hub-aks-services"
  vnet_address_space                     = ["10.88.0.0/22"]
  azure_firewall_subnet_address_prefixes = ["10.88.0.0/24"]
  azure_bastion_subnet_address_prefixes  = ["10.88.1.0/26"]
  location                               = var.location
  tags                                   = var.tags
}

# Spoke VNet (and RG) shared by multiple AKS clusters and their AGIC App Gateways
module "vnet_aks_clusters" {
  source              = "../../modules/vnet_aks_clusters"
  resource_group_name = "aks-network"
  vnet_name           = "vnet-aks-clusters"
  vnet_address_space  = ["10.89.0.0/16"]
  location            = var.location
  tags                = var.tags
}

# VNet Peering
resource "azurerm_virtual_network_peering" "hub_to_aks" {
  name                      = "hub-to-aks"
  resource_group_name       = module.vnet_hub.resource_group_name
  virtual_network_name      = module.vnet_hub.vnet_name
  remote_virtual_network_id = module.vnet_aks_clusters.vnet_id
}
resource "azurerm_virtual_network_peering" "aks_to_hub" {
  name                      = "aks-to-hub"
  resource_group_name       = module.vnet_aks_clusters.resource_group_name
  virtual_network_name      = module.vnet_aks_clusters.vnet_name
  remote_virtual_network_id = module.vnet_hub.vnet_id
}

# When using Kubenet, create 1 App Gateway per AKS cluster.
# When using Azure CNI, you can have 1 App Gateway for multiple AKS clusters.
# Note: since the App Gateway's subnet must be in the same resource group as its VNet,
# it makes sense to put the App Gateway itself in that resource group, too.
module "agw_for_aks_example_2" {
  source                              = "../../modules/app_gateway"
  app_gateway_name                    = local.aks_cluster_name
  resource_group_name                 = module.vnet_aks_clusters.vnet_resource_group_name
  vnet_name                           = module.vnet_aks_clusters.vnet_name
  app_gateway_subnet_name             = "agw-${local.aks_cluster_name}"
  app_gateway_pip_name                = "agw-${local.aks_cluster_name}"
  app_gateway_subnet_address_prefixes = ["10.89.0.0/24"]
  location                            = var.location
  tags                                = var.tags
  depends_on = [
    module.vnet_aks_clusters,
  ]
}

# Create the AKS cluster, its resource group, and a subnet for the nodes
# Note: the subnet must reside in the same resource group as its VNet, as opposed
# to the AKS cluster's resource group.
module "aks_example_2" {
  source                            = "../../modules/aks_cluster_with_byo_vnet"
  cluster_name                      = local.aks_cluster_name
  location                          = var.location
  ssh_public_key                    = var.ssh_public_key
  user_node_pool_count              = 1
  tags                              = var.tags
  sku_tier                          = "Free"
  azure_rbac_admin_group_object_ids = ["5390308c-2651-44e7-b10b-42887107a3c8"]
  # azure_rbac_reader_group_object_ids = ["5390308c-2651-44e7-b10b-42887107a3c8"]
  maintenance_allowed_windows = [{ day = "Tuesday", hours = [9, 10] }, { day = "Thursday", hours = [9, 10] }]

  # Network
  network_plugin                    = "azure"
  vnet_name                         = module.vnet_aks_clusters.vnet_name
  vnet_id                           = module.vnet_aks_clusters.vnet_id
  vnet_resource_group_name          = module.vnet_aks_clusters.vnet_resource_group_name
  vnet_resource_group_id            = module.vnet_aks_clusters.vnet_resource_group_id
  aks_nodes_subnet_address_prefixes = ["10.89.1.0/24"]

  # App Gateway
  app_gateway_enable    = true
  app_gateway_id        = module.agw_for_aks_example_2.app_gateway_id
  app_gateway_subnet_id = module.agw_for_aks_example_2.app_gateway_subnet_id

  # Azure Firewall
  outbound_type              = "userDefinedRouting"
  azure_firewall_private_ip  = module.vnet_hub.azure_firewall_private_ip
  azure_firewall_pip_address = module.vnet_hub.azure_firewall_pip_address

  depends_on = [
    module.vnet_hub,
    module.vnet_aks_clusters,
    azurerm_virtual_network_peering.hub_to_aks,
    azurerm_virtual_network_peering.aks_to_hub,
    module.agw_for_aks_example_2,
  ]
}
