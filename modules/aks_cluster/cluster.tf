resource "azurerm_kubernetes_cluster" "this" {
  location            = var.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = local.dns_prefix
  tags                = var.tags
  sku_tier            = var.sku_tier

  # Control Plane's Managed Identity
  # Use SystemAssigned id when possible, because AKS will manage its lifecycle. We need
  # UserAssigned id when using Kubenet with BYO VNet/Subnet, so we can pre-create the
  # role assignment it needs to update its Route Table.
  # https://learn.microsoft.com/en-us/azure/aks/use-managed-identity
  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = local.network_plugin
    network_plugin_mode = local.network_plugin_mode
    # Azure CNI gets Azure Network Policy Manager; Kubenet gets Calico
    network_policy = var.network_plugin == "azure" ? "azure" : "calico"
  }

  # Enable Application Gateway Ingress Controller (AGIC)
  # To disable AGIC, set local.app_gateway_enable_dynamic_block to []. 
  # Disable AGIC when using Azure CNI Overlay, as it isn't compatible.
  dynamic "ingress_application_gateway" {
    for_each = local.app_gateway_enable_dynamic_block
    content {
      subnet_cidr = var.app_gateway_cidr
      gateway_id  = var.app_gateway_id
    }
  }

  # Enable managed Azure AD integration and Azure RBAC for Kubernetes Authorization
  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = var.azure_rbac_admin_group_object_ids
  }

  # Enable Container Insights
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  # Autoscaler Profile (takes effect on any node pools where enable_auto_scaling = true)
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#balance_similar_node_groups
  auto_scaler_profile {
    skip_nodes_with_local_storage = false # OK to scale down (delete) nodes with EmptyDir or HostPath
  }

  # Enable Auto-Upgrade
  automatic_channel_upgrade = var.automatic_upgrade_channel
  maintenance_window {
    dynamic "allowed" {
      for_each = var.maintenance_allowed_windows
      content {
        day   = allowed.value.day
        hours = allowed.value.hours
      }
    }
    dynamic "not_allowed" {
      for_each = var.maintenance_not_allowed_windows
      content {
        start = not_allowed.value.begin_date_time
        end   = not_allowed.value.end_date_time
      }
    }
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
}


# User Node Pool (aka worker nodes)
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.user_node_pool_vm_size
  node_count            = var.user_node_pool_count # If using autoscaler, set this to match min_count
  zones                 = var.zones
  tags                  = var.tags

  # Autoscaler settings
  enable_auto_scaling = var.user_node_pool_autoscaler
  min_count           = var.user_node_pool_autoscaler_min_nodes
  max_count           = var.user_node_pool_autoscaler_max_nodes
  # Ignore changes to node_count if using autoscaler
  # lifecycle {
  #   ignore_changes = [
  #     node_count,
  #   ]
  # }
}
