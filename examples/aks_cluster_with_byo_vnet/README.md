# examples/aks_cluster_with_byo_vnet

## An AKS Example For BYO VNet / IP Scheme

This Terraform example illustrates how to integrate AKS into your existing IP scheme. It calls modules that create a VNet for AKS clusters (1 subnet per AKS cluster), but you could easily swap this out for your own VNet module, or call the `azurerm_virtual_network` data provider to use an existing VNet.

This example includes the integration of an AGIC subnet and a shared "hub" VNet for Azure Firewall and Azure Bastion services. This example mirrors Microsoft's [Baseline Architecture for AKS](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks).

Side note, if you want to get a feel for what extra code is needed for BYO VNet beyond simply using AKS' default auto-created VNet you can `diff` or [meld](https://meld.app/) between this example and the [default VNet example](/examples/aks_cluster_with_default_vnet).

## Major Features Covered

- BYO VNet + IP range, as opposed to the default AKS-created VNet + IP range
  - Implement Microsoft's [Baseline Architecture for AKS](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks)
  - Azure Firewall for controlling egress traffic
- Azure AD auth + Azure RBAC
- Cluster Auto-Upgrade (with maintenance windows)
- Cluster Autoscaler
- Choice of 3 network plugins: Kubenet, Azure CNI, Azure CNI Overlay
- Application Gateway Ingress Controller (AGIC)

Be sure to provide at least one `azure_rbac_admin_group_object_ids`, so that you can access your cluster after it's created.

## Azure CNI Overlay - Caveats

Azure CNI Overlay is not compatible with AGIC, so be sure to set `app_gateway_enable = false`.

Also, to use Azure CNI Overlay, you'll need to enable it as a preview feature in your Azure subscription. The most staight forward way to do this is with your `az` CLI:

```
# Install the preview extension
az extension add --name aks-preview

# Update to the latest version
az extension update --name aks-preview

# Add the CNI Overlay feature
az feature register --namespace "Microsoft.ContainerService" --name "AzureOverlayPreview"

# Wait for the status to be Registered
az feature show --namespace "Microsoft.ContainerService" --name "AzureOverlayPreview"

# Refresh the registration of the Microsoft.ContainerService resource
az provider register --namespace Microsoft.ContainerService
```

Any fan of Terraform will of course prefer to enable this within their Terraform code instead of the `az` CLI. Unfortunately, doing so doesn't work quite as well as one would hope, so your mileage may vary. To try it out, you can add the code below to your **providers.tf**. 

```
provider "azurerm" {
  features {}

  # Required for enabling features via azurerm_resource_provider_registration
  skip_provider_registration = true
}

# For Azure CNI Overlay, because it is in Preview
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_provider_registration#example-usage-registering-a-preview-feature
resource "azurerm_resource_provider_registration" "azure_cni_overlay" {
  name = "Microsoft.ContainerService"
  feature {
    name       = "AzureOverlayPreview"
    registered = true
  }
}
```

However, your first `terraform apply` will result in the following error:
> Error: A resource with the ID. “/subscriptions/xxxx-xxxx/providers/Microsoft.Network” already exists - to be managed via Terraform this resource needs to be imported into the State. Please see the resource documentation for “azurerm_resource_provider_registration” for more information.

To resolve this error, you'll need to manually import the registration into your state, like this:

```
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

terraform import azurerm_resource_provider_registration.azure_cni_overlay /subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.ContainerService
```

So, is this manual importing of state an improvement over the `az` CLI commands? I guess the answer depends on how you're deploying your Terraform. For me, having to manually import the state presents more challenges than running the `az` command. For more background/info on this issue, you can read up on it [here](https://discuss.hashicorp.com/t/how-to-enable-azure-preview-feature/43977) and [here](https://stackoverflow.com/questions/74659956/to-enable-preview-feature-of-azure-resource-provider).
