terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.3" # Or your chosen version constraint from root
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0" # Or your chosen version constraint from root
    }
    # No azurerm needed if all Azure interactions are via inputs
  }
}
