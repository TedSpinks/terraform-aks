module "azure_aks_self_contained" {
  source              = "./modules/azure_aks_self_contained"
  cluster_name        = "ted-test-aks-1"
  dns_prefix          = "ted-test-aks-1"
  resource_group_main_name_override = "ted-test-aks-1"
  location            = var.location
  ssh_public_key      = var.ssh_public_key
  tags                = local.common_tags
}
