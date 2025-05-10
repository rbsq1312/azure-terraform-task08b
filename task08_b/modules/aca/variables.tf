
variable "name" {
  type        = string
  description = "The name of the Container App"
}

variable "environment_name" {
  type        = string
  description = "The name of the Container App Environment"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The location/region of the resources"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default     = {}
}

variable "registry_server" {
  type        = string
  description = "The server URL for the container registry"
}

variable "image_name" {
  type        = string
  description = "The name of the container image"
}

variable "image_tag" {
  type        = string
  description = "The tag of the container image"
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault"
}

variable "tenant_id" {
  type        = string
  description = "The Azure AD tenant ID"
}

variable "redis_hostname_secret_uri" {
  type        = string
  description = "The URI of the Redis hostname secret in Key Vault"
}

variable "redis_password_secret_uri" {
  type        = string
  description = "The URI of the Redis password secret in Key Vault"
}
