# Create User-Assigned Identity for Container App
resource "azurerm_user_assigned_identity" "aca_identity" {
  name                = "${var.name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Grant Key Vault access policy to the identity
resource "azurerm_key_vault_access_policy" "aca_kv_access" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.aca_identity.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# Grant Key Vault Secrets User role to the identity
resource "azurerm_role_assignment" "aca_kv_role" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

# Grant ACR pull permission to the ACA identity
resource "azurerm_role_assignment" "aca_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

# Wait for role and policy propagation
resource "time_sleep" "wait_for_kv_permission_propagation" {
  depends_on = [
    azurerm_key_vault_access_policy.aca_kv_access,
    azurerm_role_assignment.aca_kv_role,
    azurerm_role_assignment.aca_acr_pull
  ]
  create_duration = "30s"
}

# Create Container App Environment
resource "azurerm_container_app_environment" "cae" {
  name                = var.environment_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  # Add this workload profile block
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}
data "azurerm_key_vault_secret" "redis_uri" {
  name         = var.redis_hostname_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "redis_key" {
  name         = var.redis_password_secret_name
  key_vault_id = var.key_vault_id
}
# Create Container App
resource "azurerm_container_app" "app" {
  depends_on = [
    time_sleep.wait_for_kv_permission_propagation
  ]

  name                         = var.name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.cae.id
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  registry {
    server   = var.registry_server
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  secret {
    name  = "redis-url"
    value = data.azurerm_key_vault_secret.redis_uri.value
  }

  secret {
    name  = "redis-key"
    value = data.azurerm_key_vault_secret.redis_key.value
  }
  template {
    container {
      name   = var.name
      image  = "${var.registry_server}/${var.image_name}:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"

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
        secret_name = "redis-url"
      }

      env {
        name        = "REDIS_PWD"
        secret_name = "redis-key"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
