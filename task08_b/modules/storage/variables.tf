variable "storage_account_name" {
  description = "Name of the Storage Account"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the Storage Account will be created"
  type        = string
}

variable "storage_account_replication_type" {
  description = "Replication type for the Storage Account (e.g., LRS, GRS)"
  type        = string
  default     = "LRS"
}

variable "storage_container_name" {
  description = "Name of the Blob Container to create"
  type        = string
}

variable "storage_blob_name" {
  description = "Name of the Blob to upload (the archive file)"
  type        = string
}

variable "source_content_path" {
  description = "Path to the directory to be archived (relative to the root module)"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the Storage Account"
  type        = map(string)
  default     = {}
}
