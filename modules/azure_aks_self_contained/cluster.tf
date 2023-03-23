resource "azurerm_kubernetes_cluster" "this" {
  location            = var.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = local.dns_prefix
  tags                = var.tags
  sku_tier            = var.sku_tier

  # Enable managed Azure AD integration and Azure RBAC for Kubernetes Authorization
  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = var.azure_rbac_admin_group_object_ids
  }

  # Dedicated System Node Pool (aka control plane nodes)
  default_node_pool {
    name       = "systempool"
    vm_size    = var.system_node_pool_vm_size
    node_count = var.system_node_pool_count
    zones      = var.zones
    tags       = var.tags
    # Taint the system nodes with CriticalAddonsOnly=true:NoSchedule
    # See https://learn.microsoft.com/en-us/azure/aks/use-system-pools?tabs=azure-cli#system-and-user-node-pools
    only_critical_addons_enabled = true
  }

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  network_profile {
    network_plugin = var.network_plugin
    # Azure CNI gets Azure Network Policy Manager; Kubenet gets Calico
    network_policy = var.network_plugin == "azure" ? "azure" : "calico"
  }

  identity {
    type = "SystemAssigned"
  }

  # Enable Container Insights
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }
}

# User Node Pool (aka worker nodes)
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.user_node_pool_vm_size
  node_count            = var.user_node_pool_count
  zones                 = var.zones
  tags                  = var.tags
}
