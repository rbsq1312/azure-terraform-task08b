# Data source to archive the application directory
data "archive_file" "application_archive" {
  type        = "tar.gz"
  source_dir  = var.source_content_path                   # This path is relative to where terraform apply is run (root)
  output_path = "${path.module}/${var.storage_blob_name}" # Temporary path for the archive
}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  tags                     = var.tags
  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication_type
}

resource "azurerm_storage_container" "app_content" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private" # As per task requirements
}

resource "azurerm_storage_blob" "app_archive_blob" {
  name                   = var.storage_blob_name
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.app_content.name
  type                   = "Block"
  source                 = data.archive_file.application_archive.output_path # Use the path of the generated archive
  # content_md5 needed if source changes frequently and you want to force re-upload
  # content_md5 = filesha256(data.archive_file.application_archive.output_path)
}
