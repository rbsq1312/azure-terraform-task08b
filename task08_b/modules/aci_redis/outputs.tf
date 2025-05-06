output "redis_fqdn" {
  description = "The FQDN of the ACI Redis instance."
  value       = azurerm_container_group.redis_ci.fqdn
}

output "redis_ip_address" {
  description = "The IP address of the ACI Redis instance (if public)."
  value       = azurerm_container_group.redis_ci.ip_address
}

output "redis_password_secret_name" {
  description = "The name of the Key Vault secret storing the Redis password."
  value       = azurerm_key_vault_secret.redis_password.name
}

output "redis_hostname_secret_name" {
  description = "The name of the Key Vault secret storing the Redis hostname."
  value       = azurerm_key_vault_secret.redis_hostname.name
}
