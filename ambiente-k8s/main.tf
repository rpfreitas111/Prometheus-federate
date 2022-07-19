terraform {
  required_version = ">= 1.2.4"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.12.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.13.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subId
  client_id       = var.appId
  client_secret   = var.password
  tenant_id       = var.tenId
}

provider "kubernetes" {
  host                   = module.w2-azurerm.host
  client_certificate     = base64decode(module.w2-azurerm.client_certificate)
  client_key             = base64decode(module.w2-azurerm.client_key)
  cluster_ca_certificate = base64decode(module.w2-azurerm.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.w2-azurerm.host
    client_certificate     = base64decode(module.w2-azurerm.client_certificate)
    client_key             = base64decode(module.w2-azurerm.client_key)
    cluster_ca_certificate = base64decode(module.w2-azurerm.cluster_ca_certificate)
  }
}



module "w2-azurerm" {
  source   = "./tfmodules/w2-azurerm"
  appId    = var.appId
  password = var.password
}

module "k8s" {
  source = "./tfmodules/k8s"
  depends_on = [
    module.w2-azurerm.kubernetes_cluster,
  ]
  resourceGroupName = module.w2-azurerm.resource_group_name
}

module "helm" {
  source     = "./tfmodules/helm"
  ingress    = module.k8s.namespace_ingress
  prometheus = module.k8s.namespace_ingress
}
