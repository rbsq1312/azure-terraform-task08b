output "storage_account_id" {
  description = "The ID of the Storage Account."
  value       = azurerm_storage_account.sa.id
}

output "storage_account_name" {
  description = "The Name of the Storage Account."
  value       = azurerm_storage_account.sa.name
}

output "storage_container_name" {
  description = "The Name of the Storage Container."
  value       = azurerm_storage_container.app_content.name
}

output "storage_blob_name" {
  description = "The Name of the uploaded Blob."
  value       = azurerm_storage_blob.app_archive_blob.name
}

output "storage_blob_url" {
  description = "The URL of the uploaded Blob."
  value       = azurerm_storage_blob.app_archive_blob.url
}

output "storage_account_primary_connection_string" {
  description = "The primary connection string for the storage account."
  value       = azurerm_storage_account.sa.primary_connection_string
  sensitive   = true
}
