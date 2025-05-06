output "key_vault_id" {
  description = "The ID of the created Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  description = "The Name of the created Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}
