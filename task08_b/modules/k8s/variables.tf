variable "acr_login_server" {
  description = "The FQDN of the ACR login server."
  type        = string
}

variable "app_image_name" {
  description = "The name of the application image in ACR (without tag)."
  type        = string
}

variable "image_tag" {
  description = "The tag of the application image to deploy."
  type        = string
  default     = "latest"
}

variable "key_vault_name" {
  description = "The name of the Azure Key Vault."
  type        = string
}

variable "redis_hostname_secret_name_in_kv" {
  description = "The name of the secret in Key Vault storing the Redis hostname."
  type        = string
}

variable "redis_password_secret_name_in_kv" {
  description = "The name of the secret in Key Vault storing the Redis password."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Tenant ID."
  type        = string
}

variable "aks_kv_identity_client_id" {
  description = "The Client ID of the AKS-managed identity that has access to Key Vault (for CSI driver). Or Object ID if System Assigned for CSI."
  type        = string
}

# Optional, if you need to override the default namespace for manifests
# variable "kubernetes_namespace" {
#   description = "The Kubernetes namespace to deploy resources into."
#   type        = string
#   default     = "default"
# }
