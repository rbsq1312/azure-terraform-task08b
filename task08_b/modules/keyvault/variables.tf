variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the Key Vault will be created"
  type        = string
}

variable "key_vault_sku" {
  description = "SKU name of the Key Vault (e.g., standard, premium)"
  type        = string
  default     = "standard"
}

variable "tags" {
  description = "A map of tags to assign to the Key Vault"
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  description = "The Azure Tenant ID where the Key Vault resides"
  type        = string
}

variable "current_user_object_id" {
  description = "The Object ID of the user or principal requiring initial access"
  type        = string
}
