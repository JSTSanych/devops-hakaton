terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name                        = "default"
    node_count                  = 2
    vm_size                     = "Standard_B2s_v2"
    temporary_name_for_rotation = "temp"
    
    # upgrade_settings повністю видалено
  }

  identity {
    type = "SystemAssigned"
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.main.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
}

resource "kubernetes_namespace_v1" "staging" {
  metadata {
    name = "staging"
    labels = {
      environment = "staging"
      managed-by  = "terraform"
    }
  }
  depends_on = [azurerm_kubernetes_cluster.main]
}

resource "kubernetes_namespace_v1" "prod" {
  metadata {
    name = "prod"
    labels = {
      environment = "production"
      managed-by  = "terraform"
    }
  }
  depends_on = [azurerm_kubernetes_cluster.main]
}
