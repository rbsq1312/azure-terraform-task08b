variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "acr_sku" {
  description = "SKU of the Azure Container Registry"
  type        = string
  default     = "Basic"
}

variable "tags" {
  description = "A map of tags to assign"
  type        = map(string)
  default     = {}
}

variable "docker_image_name" {
  description = "Name of the Docker image to build (without tag)"
  type        = string
}

variable "acr_task_build_context_blob_url" {
  description = "The full URL to the blob in Azure Storage containing the build context (e.g., app.tar.gz)."
  type        = string
}

variable "acr_task_build_context_sas_token" {
  description = "The SAS token providing read access to the build context blob."
  type        = string
  sensitive   = true
}
