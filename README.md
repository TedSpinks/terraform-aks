# terraform-aks-examples

## Purose

Azure Kubernetes Services (AKS) has tons of features and options, including the ability to leverage other Azure services such as Firewall and Application Gateway. The purpose of this repository is to exemplify how to properly combine common AKS features, as well as to document incompatible features through variable descriptions and code comments.

## Background

Initially, the Terraform examples in this repo were just a library of code snippets for enabling this feature or that feature, as I worked on projects. However, as I started combining features, I discovered that their interaction brought a lot of complexity - often the choice of one feature would introduce new requirements and/or severely limit other choices. These examples show how to properly combine features, and how to avoid common gotchas.

# Major Features Covered

- Implement Microsoft's [Baseline Architecture for AKS](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks)
- BYO VNet + IP range, as opposed to the default AKS-created VNet + IP range
- Azure AD auth + Azure RBAC
- Cluster Auto-Upgrade
- Cluster Autoscaler
- 3 network plugins: Kubenet, Azure CNI, Azure CNI Overlay
- Application Gateway Ingress Controller (AGIC)
- Azure Firewall for controlling egress traffic

# 2 Examples

## 1. AKS cluster with default VNet

The first example in `examples/aks_cluster_with_default_vnet` adds many of the above-listed features, but it does not support BYO VNet or any of the features that rely on that: Microsoft's Baseline Architecture for AKS and its shared AGIC and shared Azure Firewall.

As such, this is a very simple example, which consists of only a single Terraform module. Because it always uses the default AKS-created VNet (10.224.0.0/12) and subnet (10.224.0.0/16), it is mostly only suited to lab and learning environments, where overlapping IP Ranges won't cause any problems.

For any professional use, you will almost certainly need to integrate AKS into your existing IP scheme, which takes us to...

## .2 AKS cluster with BYO VNet

The second example in `examples/aks_cluster_with_byo_vnet` is much more useful, in that it illustrates how to create a VNet for AKS clusters within your exsiting IP scheme. It includes the integration of an AGIC subnet and a shared "hub" VNet for Azure Firewall and Azure Bastion services. This example mirrors Microsoft's [Baseline Architecture for AKS](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks).

