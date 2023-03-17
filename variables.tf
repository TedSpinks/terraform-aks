variable "location" {
  type        = string
  description = "Region where the AKS resources will reside"
  default = "westus2"
}

variable "ssh_public_key" {
  description = "SSH public key to inject into all K8s nodes"
  sensitive   = true
}
