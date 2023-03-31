variable "ssh_public_key" {
  description = "SSH public key to inject into all K8s nodes"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should added to the AKS resources"
  default     = {}
}

variable "location" {
  type        = string
  description = "Region in which all the example resources should be created"
  default     = "westus2"
}