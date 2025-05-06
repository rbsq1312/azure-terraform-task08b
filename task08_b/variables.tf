variable "name_prefix" {
  description = "Prefix for resource names, will be used to derive specific resource names."
  type        = string
  default     = "cmtr-49b8ddc2-mod8b" # Default for Task B
}

variable "location" {
  description = "The Azure region where all resources will be created."
  type        = string
  default     = "West Europe"
}

variable "creator" {
  description = "The creator of the resources (for tagging)."
  type        = string
  default     = "theodor-laurentiu_robescu@epam.com"
}

# Variables for ACR
variable "acr_sku" {
  description = "The SKU for the Azure Container Registry."
  type        = string
  default     = "Basic" # As per task parameters
}

# Variables for AKS (including the fix for Ephemeral disk with D2ads_v5)
variable "aks_node_pool_name" {
  description = "The name of the default node pool in AKS."
  type        = string
  default     = "system"
}

variable "aks_node_count" {
  description = "The number of nodes in the default node pool in AKS."
  type        = number
  default     = 1
}

variable "aks_vm_size" {
  description = "The VM size for the AKS default node pool."
  type        = string
  default     = "Standard_D2ads_v5" # As per task parameters
}

variable "aks_os_disk_type" {
  description = "The OS disk type for the AKS default node pool."
  type        = string
  default     = "Ephemeral" # As per task parameters
}

variable "default_node_pool_os_disk_size_gb" {
  description = "The OS disk size in GB for the default node pool (used with Ephemeral disks)."
  type        = number
  default     = 60 # Our determined value to make D2ads_v5 + Ephemeral work
}

# Variable for ACI (Redis)
variable "aci_sku" {
  description = "The SKU for the Azure Container Instance hosting Redis."
  type        = string
  default     = "Standard" # As per task parameters
}

# Variable for Storage Account
variable "storage_account_replication_type" {
  description = "The replication type for the Azure Storage Account."
  type        = string
  default     = "LRS" # As per task parameters
}

# Variable for Azure Container App Environment and App
variable "aca_workload_profile_type" {
  description = "The workload profile type for ACA Environment and App."
  type        = string
  default     = "Consumption" # As per task parameters
}

# Note: We are not including git_pat here for now, as the task specifies
# building the Docker image from an archive in Blob Storage, not directly from Git.
# If a Git-based trigger for the ACR task was still needed, we would add it.
