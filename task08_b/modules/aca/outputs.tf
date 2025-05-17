
output "identity_principal_id" {
  value       = azurerm_user_assigned_identity.aca_identity.principal_id
  description = "The Principal ID of the Container App's managed identity"
}

output "identity_id" {
  value       = azurerm_user_assigned_identity.aca_identity.id
  description = "The ID of the Container App's managed identity"
}

output "aca_fqdn" {
  value       = azurerm_container_app.app.latest_revision_fqdn
  description = "The FQDN of the Container App"
}

output "aca_redis_hostname_secret_uri" {
  value       = var.redis_hostname_secret_uri
  description = "The FQDN of the Container App"
}
