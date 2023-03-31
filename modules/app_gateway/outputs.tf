output "app_gateway_name" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.this.name
}

output "app_gateway_id" {
  description = "ID of the Application Gateway, which AKS clusters can use for AGIC"
  value       = azurerm_application_gateway.this.id
}

output "app_gateway_subnet_id" {
  description = "Subnet ID of the Application Gateway subnet"
  value       = azurerm_subnet.application_gateway.id
}

output "app_gateway_subnet_name" {
  description = "Name of the Application Gateway subnet"
  value       = azurerm_subnet.application_gateway.name
}

output "app_gateway_subnet_address_prefixes" {
  description = "List of the Application Gateway subnet's address prefixes"
  value       = azurerm_subnet.application_gateway.address_prefixes
}

output "app_gateway_pip_id" {
  description = "ID of the Application Gateway's Public IP address"
  value       = azurerm_public_ip.application_gateway.id
}

output "app_gateway_pip_name" {
  description = "Name of the Azure Firewall's Public IP address"
  value       = azurerm_public_ip.application_gateway.name
}

output "app_gateway_pip_address" {
  description = "Public IP address of the Azure Firewall"
  value       = azurerm_public_ip.application_gateway.ip_address
}
