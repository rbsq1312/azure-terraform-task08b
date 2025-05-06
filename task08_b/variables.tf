variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "cmtr-49b8ddc2-mod8b" # Updated default for task B
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "creator" {
  description = "The creator of the resources"
  type        = string
  default     = "theodor-laurentiu_robescu@epam.com"
}

# No git variables needed for build context, but ACR task trigger might still use them if configured
# variable "git_pat" {
#   description = "The Personal Access Token for the Git repository (if needed for triggers)"
#   type        = string
#   sensitive   = true
# }

variable "acr_sku" {
  description = "The SKU of the ACR"
  type        = string
  default     = "Basic"
}

# --- Add AKS Variables (including disk size fix) ---
variable "aks_node_pool_name" {
  description = "The name of the default node pool in AKS"
  type        = string
  default     = "system"
}

variable "aks_node_count" {
  description = "The number of nodes in the default node pool in AKS"
  type        = number
  default     = 1
}

variable "aks_vm_size" {
  description = "The size of the Virtual Machine in the default node pool in AKS"
  type        = string
  default     = "Standard_D2ads_v5" # Task parameter
}

variable "aks_os_disk_type" {
  description = "The type of OS disk in the default node pool in AKS"
  type        = string
  default     = "Ephemeral" # Task parameter
}

variable "default_node_pool_os_disk_size_gb" {
  description = "The size of the OS disk in GB for the default node pool (set to ~60 for Ephemeral on D2ads_v5)"
  type        = number
  default     = 60 
}

# Add other variables as needed by modules (e.g., ACI SKU, ACA profile type, Storage replication type)
variable "aci_sku" {
  description = "The SKU for the ACI Redis instance"
  type        = string
  default     = "Standard"
}

variable "aca_workload_profile_type" {
  description = "The Workload Profile Type for ACA Environment and App"
  type        = string
  default     = "Consumption"
}

variable "storage_account_replication_type" {
  description = "Replication type for Storage Account"
  type        = string
  default     = "LRS"
}
