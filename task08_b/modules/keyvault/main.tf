resource "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = var.key_vault_sku
  tags                = var.tags

  # Enable purge protection and soft delete (Good Practice)
  enable_rbac_authorization  = false # Using Access Policies as per task
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Can be true, but makes deletion harder during testing
}

# Standalone access policy for the current user/principal running Terraform
# Grants full permissions for secrets as requested by the task description implicitly
resource "azurerm_key_vault_access_policy" "current_user_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = var.tenant_id
  object_id    = var.current_user_object_id

  # Grant permissions needed by the user/SP running terraform 
  # AND potentially for manual checks/deletions later
  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge",
    "Backup",
    "Restore",
    "Recover"
  ]

  # Add key/certificate permissions if needed, but task focused on secrets
  # key_permissions = [ ... ]
  # certificate_permissions = [ ... ]
}

