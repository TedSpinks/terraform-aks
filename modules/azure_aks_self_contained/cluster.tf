resource "azurerm_kubernetes_cluster" "k8s" {
  location            = var.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  tags = var.tags

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.agent_count
  }
  
  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = var.ssh_public_key
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

  # This block ties the cluster to the Log Analytics Workspace
  # https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-enable-aks?tabs=terraform
  oms_agent {
    log_analytics_workspace_id = "${azurerm_log_analytics_workspace.test.id}"
  }
}