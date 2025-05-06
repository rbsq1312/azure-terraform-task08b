output "aca_fqdn" {
  description = "The FQDN of the Azure Container App."
  value       = azurerm_container_app.app.latest_revision_fqdn
}

output "aca_id" {
  description = "The ID of the Azure Container App."
  value       = azurerm_container_app.app.id
}

output "user_assigned_identity_id" {
  description = "The ID of the User Assigned Identity created for ACA."
  value       = azurerm_user_assigned_identity.aca_identity.id
}

output "user_assigned_identity_principal_id" {
  description = "The Principal ID of the User Assigned Identity created for ACA."
  value       = azurerm_user_assigned_identity.aca_identity.principal_id
}
