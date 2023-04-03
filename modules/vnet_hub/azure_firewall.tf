resource "azurerm_subnet" "azure_firewall" {
  # Name must be exactly 'AzureFirewallSubnet' to be used for the Azure Firewall resource
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.azure_firewall_subnet_address_prefixes
}

resource "azurerm_public_ip" "azure_firewall" {
  name                = var.azure_firewall_pip_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy" "this" {
  name                = "dns-proxy"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  dns {
    proxy_enabled = true
  }
}

resource "azurerm_firewall" "this" {
  name                = var.azure_firewall_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.this.id
  # tags                = var.tags # Throws an error, maybe TF provider bug

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.azure_firewall.id
    public_ip_address_id = azurerm_public_ip.azure_firewall.id
  }
}

# Create firewall rules for AKS
# Reference: https://learn.microsoft.com/en-us/azure/aks/limit-egress-traffic#adding-firewall-rules
resource "azurerm_firewall_policy_rule_collection_group" "aks" {
  name               = "aks"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 500
  application_rule_collection {
    name     = "aksfwar"
    priority = 100
    action   = "Allow"
    rule {
      name = "aks-services"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses      = ["*"]
      destination_fqdn_tags = ["AzureKubernetesService"]
    }
    # Example of a rule to allow pulling images from your image registry (Docker in this example)
    rule {
      name = "docker"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["docker.io", "*.docker.io", "*.docker.com"]
    }
  }
  network_rule_collection {
    name     = "aksfwnr"
    priority = 200
    action   = "Allow"
    rule {
      name                  = "apiudp"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["AzureCloud.${var.location}"]
      destination_ports     = ["1194"]
    }
    rule {
      name                  = "apitcp"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["AzureCloud.${var.location}"]
      destination_ports     = ["9000"]
    }
    rule {
      name              = "time"
      protocols         = ["UDP"]
      source_addresses  = ["*"]
      destination_fqdns = ["ntp.ubuntu.com"]
      destination_ports = ["123"]
    }
  }
}
