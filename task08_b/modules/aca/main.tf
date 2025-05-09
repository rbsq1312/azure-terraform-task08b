# Create a User-Assigned Managed Identity for the Container App
resource "azurerm_user_assigned_identity" "aca_identity" {
  name                = "${var.aca_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Grant the ACA's Managed Identity access to pull from ACR
resource "azurerm_role_assignment" "aca_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

# Data block to get current client config
data "azurerm_client_config" "current" {}

# Grant the ACA's Managed Identity access to get secrets from Key Vault
resource "azurerm_key_vault_access_policy" "aca_kv_access" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.aca_identity.principal_id
  secret_permissions = [
    "Get",
    "List" # List permission can be useful for some scenarios, "Get" is essential.
  ]
}

# Data source to get Key Vault details (Optional if var.key_vault_id is sufficient for all needs)
# This data block itself might not be strictly necessary if you already have var.key_vault_id
# and other details. The depends_on here was unusual for a data block.
# If it's causing issues or isn't used elsewhere, consider removing.
# For now, keeping as per your structure but noting it.
data "azurerm_key_vault" "aca_kv" {
  name                = split("/", var.key_vault_id)[8] # This extracts name from ID, ensure ID format is consistent
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_key_vault_access_policy.aca_kv_access
  ]
}

# Add wait time for Key Vault permissions to propagate
resource "time_sleep" "wait_for_kv_permission_propagation" {
  depends_on = [
    azurerm_key_vault_access_policy.aca_kv_access
  ]
  create_duration = "5m" # This is quite long, 2m might be sufficient, but 5m is safer if you've faced issues.
}

# Add data sources to fetch Key Vault secrets
data "azurerm_key_vault_secret" "redis_hostname" {
  name         = var.redis_hostname_secret_name_in_kv # Ensure this variable is "redis-hostname"
  key_vault_id = var.key_vault_id
  depends_on = [
    # Ensure secrets are created in KV by aci_redis module first if this module depends on it implicitly.
    # And that KV access policy is applied.
    time_sleep.wait_for_kv_permission_propagation # Good for ensuring permissions are active
  ]
}

data "azurerm_key_vault_secret" "redis_password" {
  name         = var.redis_password_secret_name_in_kv # Ensure this variable is "redis-password"
  key_vault_id = var.key_vault_id
  depends_on = [
    time_sleep.wait_for_kv_permission_propagation
  ]
}

# Create Azure Container App Environment (ACAE)
resource "azurerm_container_app_environment" "cae" {
  name                = var.aca_env_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  workload_profile {
    name                  = "Consumption" # As per task (Consumption Profile)
    workload_profile_type = var.workload_profile_type
    minimum_count         = 0 # Default for Consumption often managed by Azure
    maximum_count         = 1 # Default for Consumption often managed by Azure
  }
}

# Create Azure Container App (ACA)
resource "azurerm_container_app" "app" {
  name                         = var.aca_name
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  secrets = [ # CORRECTED SYNTAX: This is now a list of secret objects
    {
      name                = "redis-url"                                     # ACA-internal secret name
      key_vault_secret_id = data.azurerm_key_vault_secret.redis_hostname.id # References the KV secret "redis-hostname"
      identity            = azurerm_user_assigned_identity.aca_identity.id
    },
    {
      name                = "redis-key"                                     # ACA-internal secret name
      key_vault_secret_id = data.azurerm_key_vault_secret.redis_password.id # References the KV secret "redis-password"
      identity            = azurerm_user_assigned_identity.aca_identity.id
    }
  ]

  template {
    container {
      name   = var.aca_name # Or a more generic name like "app-container"
      image  = var.docker_image_to_deploy
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "CREATOR"
        value = "ACA"
      }
      env {
        name  = "REDIS_PORT"
        value = "6379"
      }
      env {
        name        = "REDIS_URL"
        secret_name = "redis-url" # References the ACA-internal secret named "redis-url"
      }
      env {
        name        = "REDIS_PWD"
        secret_name = "redis-key" # References the ACA-internal secret named "redis-key"
      }
    }
    min_replicas = 0 # For Consumption, often this is 0 or 1 based on traffic
    max_replicas = 1 # Ensure this meets actual scaling needs; for the task, 1 is fine.
  }

  ingress {
    external_enabled = true
    target_port      = 8080 # App listens on 8080
    # allow_insecure_connections = false # Default, good practice
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [
    azurerm_user_assigned_identity.aca_identity,
    azurerm_role_assignment.aca_acr_pull,
    azurerm_key_vault_access_policy.aca_kv_access,
    # data.azurerm_key_vault.aca_kv, # Not strictly needed here if not directly used for resource creation logic
    # data.azurerm_key_vault_secret.redis_hostname, # Implicitly handled by referencing its ID
    # data.azurerm_key_vault_secret.redis_password, # Implicitly handled
    time_sleep.wait_for_kv_permission_propagation
  ]
}
