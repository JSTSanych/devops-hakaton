output "cluster_endpoint" {
  description = "AKS cluster endpoint"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].host
  sensitive   = true
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.main.name
}

output "kubectl_connection" {
  description = "Command to connect to cluster"
  value       = "az aks get-credentials --resource-group ${data.azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

output "resource_group_name" {
  description = "Resource group name"
  value       = data.azurerm_resource_group.main.name  # змінено: data.azurerm_resource_group
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = azurerm_kubernetes_cluster.main.kubernetes_version
}
