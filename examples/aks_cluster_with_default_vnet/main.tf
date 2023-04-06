# Example 1: Standalone AKS module, which lets AKS auto-create the default VNet and Subnets
# Default VNet: 10.224.0.0/12
# Default subnet: 10.224.0.0/16

module "azure_aks_default_vnet_example" {
  source                            = "../../modules/aks_cluster"
  cluster_name                      = "aks-example-1"
  location                          = var.location
  ssh_public_key                    = var.ssh_public_key
  user_node_pool_count              = 1
  tags                              = var.tags
  sku_tier                          = "Free"
  app_gateway_enable                = true
  azure_rbac_admin_group_object_ids = ["5390308c-2651-44e7-b10b-42887107a3c8"]
  # azure_rbac_reader_group_object_ids = ["5390308c-2651-44e7-b10b-42887107a3c8"]
  maintenance_allowed_windows = [{ day = "Tuesday", hours = [9, 10] }, { day = "Thursday", hours = [9, 10] }]
}

