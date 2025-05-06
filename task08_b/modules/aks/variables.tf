variable "resource_group_name" {
  description = "The name of the resource group in which to create the AKS"
  type        = string
}

variable "location" {
  description = "The location/region where the AKS is created"
  type        = string
}

variable "aks_name" {
  description = "The name of the AKS"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster"
  type        = string
}

variable "node_pool_name" {
  description = "The name of the default node pool"
  type        = string
}

variable "node_count" {
  description = "The number of nodes in the default node pool"
  type        = number
}

variable "vm_size" {
  description = "The size of the Virtual Machine in the default node pool"
  type        = string
}

variable "os_disk_type" {
  description = "The type of OS disk in the default node pool"
  type        = string
}

variable "default_node_pool_os_disk_size_gb" {
  description = "OS Disk size in GB for the default node pool."
  type        = number
}

variable "acr_id" {
  description = "The ID of the Azure Container Registry to grant pull access to."
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Azure Key Vault for CSI driver integration."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID for Key Vault access policy."
  type        = string
}
