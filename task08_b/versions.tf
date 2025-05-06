terraform {
  required_version = ">= 1.5.7" # Example, adjust as needed

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.110.0, < 4.0.0" # From previous task
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0" # For random password
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0" # For creating archive
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7" # For SAS timestamps / potential sleep
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.0" # From previous task
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0" # From previous task
    }
  }
}

# Configure Azure provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Configure K8s/Kubectl providers - Will need outputs from AKS module later
# Placeholder configuration (won't work until AKS module provides outputs)
provider "kubectl" {
  # Configuration depends on AKS module outputs
  # host                   = module.aks.host 
  # client_certificate     = base64decode(module.aks.client_certificate)
  # client_key             = base64decode(module.aks.client_key)
  # cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  load_config_file       = false # Usually false when configured directly
  alias                  = "k8s" # Alias if using separate k8s module
}

provider "kubernetes" {
  # Configuration depends on AKS module outputs
  # host                   = module.aks.host
  # client_certificate     = base64decode(module.aks.client_certificate)
  # client_key             = base64decode(module.aks.client_key)
  # cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  alias                  = "k8s" # Alias if using separate k8s module
}
