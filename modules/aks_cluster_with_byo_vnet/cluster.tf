resource "azurerm_kubernetes_cluster" "this" {
  location            = var.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = local.dns_prefix
  tags                = var.tags
  sku_tier            = var.sku_tier

  # Control Plane's Managed Identity
  # Use SystemAssigned id when possible, because AKS will give it all the needed permissions. 
  # We need UserAssigned id when using Kubenet with BYO VNet/Subnet, so we can pre-create the
  # role assignment it needs to update its Route Table.
  # https://learn.microsoft.com/en-us/azure/aks/use-managed-identity
  identity {
    type         = local.managed_identity_type
    identity_ids = (local.managed_identity_type == "UserAssigned") ? [azurerm_user_assigned_identity.this[0].id] : null
  }

  network_profile {
    network_plugin      = local.network_plugin
    network_plugin_mode = local.network_plugin_mode
    # Azure CNI gets Azure Network Policy Manager; Kubenet gets Calico
    network_policy = var.network_plugin == "azure" ? "azure" : "calico"
    # Change the default internal IP ranges if they conflict with your real network
    pod_cidr           = var.network_pod_cidr
    service_cidr       = var.network_service_cidr
    dns_service_ip     = var.network_dns_service_ip
    docker_bridge_cidr = var.network_docker_bridge_cidr
    # Egress type. Default is loadBalancer. For Azure Firewall, use userDefinedRouting
    outbound_type = var.outbound_type
  }

  # Enable Application Gateway Ingress Controller (AGIC)
  # Set var.enable_app_gateway_dynamic_block to [] if you need to disable AGIC (it's not compatible with Azure CNI Overlay)
  dynamic "ingress_application_gateway" {
    for_each = local.enable_app_gateway_dynamic_block
    content {
      gateway_id = var.app_gateway_id
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
    name           = "systempool"
    vnet_subnet_id = azurerm_subnet.cluster_nodes.id
    vm_size        = var.system_node_pool_vm_size
    node_count     = var.system_node_pool_count
    zones          = var.zones
    tags           = var.tags
    # Taint the system nodes with CriticalAddonsOnly=true:NoSchedule
    # See https://learn.microsoft.com/en-us/azure/aks/use-system-pools?tabs=azure-cli#system-and-user-node-pools
    only_critical_addons_enabled = true
  }

  depends_on = [
    azurerm_route_table.cluster_nodes,
    azurerm_route.aks_egress_fwrn,
    azurerm_route.aks_egress_fwinternet,
    azurerm_subnet_route_table_association.cluster_nodes,
    azurerm_subnet_route_table_association.app_gateway,
  ]
}


# User Node Pool (aka worker nodes)
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vnet_subnet_id        = azurerm_subnet.cluster_nodes.id
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
