output "resource_group_name" {
  description = "Name of the Resource Group in which the VNet lives"
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.this.name
}

output "vnet_address_spaces" {
  description = "List of address ranges within the Virtual Network"
  value       = azurerm_virtual_network.this.address_space
}

output "vnet_guid" {
  description = "GUID of the Virtual Network"
  value       = azurerm_virtual_network.this.guid
}

output "vnet_resource_group_name" {
  description = "Name the Resource Group in which the Virtual Network lives"
  value       = azurerm_resource_group.this.name
}

output "vnet_resource_group_id" {
  description = "ID the Resource Group in which the Virtual Network lives"
  value       = azurerm_resource_group.this.id
}

output "vnet_location" {
  description = "Location in which the Resource Group, VNet, and App Gateway live"
  value       = azurerm_resource_group.this.location
}
