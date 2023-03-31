# Note: we don't need to bother with NSGs for the Azure Bastion subnet
# Reference: https://docs.microsoft.com/en-us/azure/bastion/bastion-overview#key

# Bastion Subnet
resource "azurerm_subnet" "azure_bastion" {
  # Name must be exactly 'AzureBastionSubnet' to be used for the Azure Bastion Host resource
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.azure_bastion_subnet_address_prefixes
}

# Public IP
resource "azurerm_public_ip" "azure_bastion" {
  name                = var.azure_bastion_pip_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Azure Bastion Service Host
resource "azurerm_bastion_host" "this" {
  name                = var.azure_bastion_host_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.azure_bastion.id
    public_ip_address_id = azurerm_public_ip.azure_bastion.id
  }

  tags = var.tags
}
