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
    "List"
  ]
}

# Data source to get Key Vault details
data "azurerm_key_vault" "aca_kv" {
  name                = split("/", var.key_vault_id)[8]
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
  create_duration = "5m"
}

# Create Azure Container App Environment (ACAE)
resource "azurerm_container_app_environment" "cae" {
  name                = var.aca_env_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = var.workload_profile_type
    minimum_count         = 0
    maximum_count         = 1
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

  # Add secrets with references to Key Vault
  secret {
    name                = "redis-url"
    key_vault_secret_id = "${trimsuffix(data.azurerm_key_vault.aca_kv.vault_uri, "/")}/secrets/${var.redis_hostname_secret_name_in_kv}/latest"
    identity            = azurerm_user_assigned_identity.aca_identity.id
  }

  secret {
    name                = "redis-key"
    key_vault_secret_id = "${trimsuffix(data.azurerm_key_vault.aca_kv.vault_uri, "/")}/secrets/${var.redis_password_secret_name_in_kv}/latest"
    identity            = azurerm_user_assigned_identity.aca_identity.id
  }

  template {
    container {
      name   = var.aca_name
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

      # Use secret references for environment variables
      env {
        name        = "REDIS_URL"
        secret_name = "redis-url"
      }

      env {
        name        = "REDIS_PWD"
        secret_name = "redis-key"
      }
    }

    min_replicas = 0
    max_replicas = 1
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [
    azurerm_user_assigned_identity.aca_identity,
    azurerm_role_assignment.aca_acr_pull,
    azurerm_key_vault_access_policy.aca_kv_access,
    data.azurerm_key_vault.aca_kv,
    time_sleep.wait_for_kv_permission_propagation
  ]
}
