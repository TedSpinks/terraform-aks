# examples/aks_cluster_with_default_vnet

## A Simple AKS Module Example

This Terraform example calls a single module for a simple AKS cluster, in which AKS auto-creates the default VNet (10.224.0.0/12) and default subnet (10.224.0.0/16). Is also uses the default pod CIDR (10.244.0.0/16) and service CIDR (10.0.0.0/16). If you tell it to enable the Application Gateway Ingress Controller (AGIC), then AKS also auto-creates an AGIC subnet (10.225.0.0/24).

Because this simple module uses all the default auto-created IP ranges, its usefulness is mostly limited to lab and learning environments, where duplicating these IP ranges won't cause any problems. For professional scenarios where you want to integrate AKS into your existing IP scheme, check out the other, more [extensive example](/examples/aks_cluster_with_byo_vnet/README.md). In which case, being able to `diff` or [meld](https://meld.app/) between the 2 examples might help provide some additional context for understanding the additions of the more extensive example.

## Major Features Covered

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

So, is this manual importing of state an improvement over the `az` CLI commands? I guess the answer depends on how you're deploying your Terraform. For me, having to manually import the state presents more challenges than running the `az` commands. For more background/info on this issue, you can read up on it [here](https://discuss.hashicorp.com/t/how-to-enable-azure-preview-feature/43977) and [here](https://stackoverflow.com/questions/74659956/to-enable-preview-feature-of-azure-resource-provider).
