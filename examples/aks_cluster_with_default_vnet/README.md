# examples/aks_cluster_with_default_vnet

## A Simple AKS Module Example

This Terraform example calls a single module for a simple AKS cluster, in which AKS auto-creates the default VNet (10.224.0.0/12) and default subnet (10.224.0.0/16). Is also uses the default pod CIDR (10.244.0.0/16) and service CIDR (10.0.0.0/16). If you tell it to enable the Application Gateway Ingress Controller (AGIC), then AKS also auto-creates an AGIC subnet (10.225.0.0/24).

Because this simple module uses all the default auto-created IP ranges, its usefulness is mostly limited to lab and test environments, where duplicating these IP ranges won't cause any problems. For more common scenarios where you want to integrate AKS into your existing IP scheme, check out the other, more [extensive example](/examples/aks_cluster_with_byo_vnet). In which case, being able to `diff` or [meld](https://meld.app/) between the 2 examples might help provide some additional context for understanding the additions of the more extensive example.

## Major Features Covered

- Azure AD auth + Azure RBAC
- Container Insights (monitoring)
- Cluster Auto-Upgrade (with maintenance windows)
- Cluster Autoscaler
- Choice of 3 network plugins: Kubenet, Azure CNI, Azure CNI Overlay
- Private K8s API Server
- Application Gateway Ingress Controller (AGIC)

Be sure to provide at least one `azure_rbac_admin_group_object_ids`, so that you can access your cluster after it's created.

## Azure CNI Overlay - Caveats

Azure CNI Overlay is not compatible with AGIC, so be sure to set `app_gateway_enable = false`.
