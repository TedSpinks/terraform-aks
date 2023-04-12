module "azure_aks_default_vnet_example" {
  source                            = "../../modules/aks_cluster"
  cluster_name                      = "aks-example-1"
  location                          = var.location
  ssh_public_key                    = var.ssh_public_key
  user_node_pool_count              = 1
  network_plugin                    = "kubenet"
  # app_gateway_enable                = false # false when network_plugin = azureoverlay
  tags                              = var.tags
  sku_tier                          = "Free"
  azure_rbac_admin_group_object_ids = ["5390308c-2651-44e7-b10b-42887107a3c8"]
  # azure_rbac_reader_group_object_ids = ["5390308c-2651-44e7-b10b-42887107a3c8"]
  maintenance_allowed_windows = [{ day = "Tuesday", hours = [9, 10] }, { day = "Thursday", hours = [9, 10] }]
}
