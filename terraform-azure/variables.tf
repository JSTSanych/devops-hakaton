variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "devops-hakaton-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "online-boutique-aks"
}

variable "dns_prefix" {
  description = "DNS prefix for AKS"
  type        = string
  default     = "boutique"
}
