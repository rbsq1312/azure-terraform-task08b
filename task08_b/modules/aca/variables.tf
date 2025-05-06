variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign"
  type        = map(string)
  default     = {}
}

variable "aca_env_name" {
  description = "Name for the Azure Container App Environment."
  type        = string
}

variable "aca_name" {
  description = "Name for the Azure Container App."
  type        = string
}

variable "workload_profile_type" {
  description = "The workload profile type for the Container App Environment (e.g., Consumption)."
  type        = string
  default     = "Consumption"
}

variable "docker_image_to_deploy" {
  description = "The full name of the Docker image to deploy (e.g., myacr.azurecr.io/myapp:latest)."
  type        = string
}

variable "acr_id" {
  description = "The ID of the Azure Container Registry for image pull permissions."
  type        = string
}

variable "acr_login_server" {
  description = "The login server of the Azure Container Registry."
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Azure Key Vault for secret access."
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
