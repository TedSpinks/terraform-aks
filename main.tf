module "azure_aks_self_contained_test1" {
  source               = "./modules/azure_aks_self_contained"
  cluster_name         = "ted-test-aks-1"
  location             = "westus2"
  ssh_public_key       = var.ssh_public_key
  user_node_pool_count = 1
  network_plugin       = "kubenet"
  tags                 = var.tags
}

module "azure_aks_self_contained_test2" {
  source                   = "./modules/azure_aks_self_contained"
  cluster_name             = "ted-test-aks-2"
  location                 = "westus2"
  ssh_public_key           = var.ssh_public_key
  user_node_pool_count     = 1
  system_node_pool_vm_size = "Standard_D2_v3"
  user_node_pool_vm_size   = "Standard_D2_v3"
  tags                     = var.tags
}
