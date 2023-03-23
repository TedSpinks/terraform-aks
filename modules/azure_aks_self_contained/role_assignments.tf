resource "azurerm_role_assignment" "readers" {
  count                = length(var.azure_rbac_reader_group_object_ids)
  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = var.azure_rbac_reader_group_object_ids[count.index]
}
