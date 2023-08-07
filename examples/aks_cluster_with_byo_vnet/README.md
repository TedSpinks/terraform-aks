# examples/aks_cluster_with_byo_vnet

## An AKS Example For BYO VNet / IP Scheme

This Terraform example illustrates how to integrate AKS into your existing IP scheme. It calls modules that create VNets for shared resources (Firewall, Bastion) and for AKS clusters (1 subnet per AKS cluster), but you could easily swap these out for your own modules, and/or call the `azurerm_virtual_network` data provider to use existing VNets.

This example also mirrors Microsoft's [Baseline Architecture for AKS](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks), which includes the integration of an AGIC subnet and a shared "hub" VNet for Azure Firewall and Azure Bastion services.

Side note, if you want to get a feel for what additional Terraform code is needed when moving from AKS' default auto-created VNet to a BYO VNet scenario, you can `diff` or [meld](https://meld.app/) between this example and the [default VNet example](/examples/aks_cluster_with_default_vnet).

## Major Features Covered

- BYO VNet + IP range, as opposed to the default AKS-created VNet + IP range
  - Implement Microsoft's [Baseline Architecture for AKS](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks)
  - Azure Firewall for controlling egress traffic
- Azure AD auth + Azure RBAC
- Container Insights (monitoring)
- Cluster Auto-Upgrade (with maintenance windows)
- Cluster Autoscaler
- Choice of 3 network plugins: Kubenet, Azure CNI, Azure CNI Overlay
- Application Gateway Ingress Controller (AGIC)

Be sure to provide at least one `azure_rbac_admin_group_object_ids`, so that you can access your cluster after it's created.

## How to use AGIC with each CNI

- Azure CNI - You can share 1 App Gateway across multiple AKS clusters.
- Azure CNI Overlay - not compatible with AGIC, so be sure to set `app_gateway_enable = false`.
- Kubenet - When using Kubenet, create a separate App Gateway per AKS cluster. This is needed because Kubenet manages its own routes to direct traffic to each pod through the specific nodes on which it lives. In order for AGIC to communicate with pods, you'll need to assign the Kubenet-managed Route Table to the App Gateway subnet. Because you can only assign 1 Route Table per subnet, this effectively limits the AGIC to 1 Kubenet AKS cluster.

Also, since the App Gateway's subnet must be in the same resource group as its VNet, it makes sense to put the App Gateway itself in that resource group, too.
