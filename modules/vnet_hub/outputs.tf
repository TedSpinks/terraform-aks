output "resource_group_name" {
  description = "Name of the Resource Group in which the VNet lives"
  value       = azurerm_resource_group.this.name
}

# --------------------------------------- VNet Details ----------------------------------------

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

# ---------------------------------- Azure Firewall Details -----------------------------------

output "azure_firewall_name" {
  description = "ID of the firewall host"
  value       = azurerm_firewall.this.name
}

output "azure_firewall_private_ip" {
  description = "ID of the firewall host"
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "azure_firewall_id" {
  description = "ID of the firewall host"
  value       = azurerm_firewall.this.id
}

output "azure_firewall_subnet_id" {
  description = "Subnet ID of the firewall subnet"
  value       = azurerm_subnet.azure_firewall.id
}

output "azure_firewall_subnet_name" {
  description = "Name of the Azure Firewall subnet"
  value       = azurerm_subnet.azure_firewall.name
}

output "azure_firewall_subnet_address_prefixes" {
  description = "List of the Azure Firewall subnet's address prefixes"
  value       = azurerm_subnet.azure_firewall.address_prefixes
}

output "azure_firewall_pip_id" {
  description = "ID of the Azure Firewall's Public IP address"
  value       = azurerm_public_ip.azure_firewall.id
}

output "azure_firewall_pip_name" {
  description = "Name of the Azure Firewall's Public IP address"
  value       = azurerm_public_ip.azure_firewall.name
}

output "azure_firewall_pip_address" {
  description = "Public IP address of the Azure Firewall"
  value       = azurerm_public_ip.azure_firewall.ip_address
}

# ----------------------------------- Azure Bastion Details -----------------------------------

output "azure_bastion_host_name" {
  description = "Name of the bastion host service"
  value       = azurerm_bastion_host.this.dns_name
}

output "azure_bastion_host_fqdn" {
  description = "FQDN of the bastion host"
  value       = azurerm_bastion_host.this.dns_name
}

output "azure_bastion_host_id" {
  description = "ID of the bastion host"
  value       = azurerm_bastion_host.this.id
}

output "azure_bastion_subnet_id" {
  description = "Subnet ID of the bastion subnet"
  value       = azurerm_subnet.azure_bastion.id
}

output "azure_bastion_subnet_name" {
  description = "Name of the bastion subnet"
  value       = azurerm_subnet.azure_bastion.name
}

output "azure_bastion_subnet_address_prefixes" {
  description = "List of the bastion subnet's address prefixes"
  value       = azurerm_subnet.azure_bastion.address_prefixes
}

output "azure_bastion_host_pip_id" {
  description = "ID of the bastion host's Public IP address"
  value       = azurerm_public_ip.azure_bastion.id
}

output "azure_bastion_host_pip_name" {
  description = "Name of the bastion host's Public IP address"
  value       = azurerm_public_ip.azure_bastion.name
}

output "azure_bastion_host_pip_address" {
  description = "Public IP address of the bastion host"
  value       = azurerm_public_ip.azure_bastion.ip_address
}
