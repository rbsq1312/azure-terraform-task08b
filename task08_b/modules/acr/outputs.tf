output "acr_id" {
  description = "The ID of the Azure Container Registry."
  value       = azurerm_container_registry.acr.id
}

output "acr_login_server" {
  description = "The FQDN of the Azure Container Registry login server."
  value       = azurerm_container_registry.acr.login_server
}

output "acr_name" {
  description = "The name of the Azure Container Registry."
  value       = azurerm_container_registry.acr.name
}

# This output can be used by ACI/ACA/AKS to reference the image
output "docker_image_full_name_latest" {
  description = "The full image name with the 'latest' tag."
  value       = "${azurerm_container_registry.acr.login_server}/${var.docker_image_name}:latest"
}

# Output for admin credentials if admin_enabled = true (useful for ACI without managed identity)
output "acr_admin_username" {
  description = "The admin username for the ACR (if admin_enabled)."
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "The admin password for the ACR (if admin_enabled)."
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}
