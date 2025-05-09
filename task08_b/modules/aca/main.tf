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

  #  Use Key Vault reference instead of fetching value
  secret {
    name          = "redis-url"
    key_vault_url = data.azurerm_key_vault_secret.redis_hostname.id
    identity      = azurerm_user_assigned_identity.aca_identity.id
  }

  secret {
    name          = "redis-key"
    key_vault_url = data.azurerm_key_vault_secret.redis_password.id
    identity      = azurerm_user_assigned_identity.aca_identity.id
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

      # Secure environment variable mapping
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
    data.azurerm_key_vault_secret.redis_hostname,
    data.azurerm_key_vault_secret.redis_password,
    time_sleep.wait_for_kv_permission_propagation
  ]
}

