variable "resource_group_name" {
  description = "The name of the resource group where ACI will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where ACI will be created."
  type        = string
}

variable "aci_redis_name" {
  description = "The name for the Azure Container Instance for Redis."
  type        = string
}

variable "aci_sku" {
  description = "The SKU for the Azure Container Instance (e.g., Standard)."
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "A map of tags to assign to the ACI resource."
  type        = map(string)
  default     = {}
}

variable "key_vault_id" {
  description = "The ID of the Azure Key Vault where Redis credentials will be stored."
  type        = string
}

variable "redis_hostname_secret_name" {
  description = "The name of the Key Vault secret to store the Redis hostname (ACI FQDN)."
  type        = string
}

variable "redis_password_secret_name" {
  description = "The name of the Key Vault secret to store the Redis password."
  type        = string
}

# Optional: If you need to deploy ACI into a VNet for private access
# variable "subnet_ids" {
#   description = "A list of subnet IDs to deploy the ACI into."
#   type        = list(string)
#   default     = null
# }
