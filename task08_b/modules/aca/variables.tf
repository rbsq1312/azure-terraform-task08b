
variable "name" {
  description = "The name of the Container App"
  type        = string
}

variable "environment_name" {
  description = "The name of the Container App Environment"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location/region of the resources"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {}
}

variable "registry_server" {
  description = "The server URL for the container registry"
  type        = string
}

variable "image_name" {
  description = "The name of the container image"
  type        = string
}

variable "image_tag" {
  description = "The tag of the container image"
  type        = string
  default     = "latest"
}

variable "key_vault_id" {
  description = "The ID of the Key Vault"
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
}

variable "redis_hostname_secret_uri" {
  description = "The URI of the Redis hostname secret in Key Vault"
  type        = string
}

variable "redis_password_secret_uri" {
  description = "The URI of the Redis password secret in Key Vault"
  type        = string
}

variable "workload_profile_type" {
  description = "The workload profile type for the Container App"
  type        = string
  default     = "Consumption"
}
