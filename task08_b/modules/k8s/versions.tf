terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      # Inherit version constraint or set specific one
      # Ensure configuration block uses aliased provider from root if needed
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
       # Inherit version constraint or set specific one
       # Ensure configuration block uses aliased provider from root if needed
    }
  }
}
