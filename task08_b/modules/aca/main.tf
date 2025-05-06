# Create a User-Assigned Managed Identity for the Container App
resource "azurerm_user_assigned_identity" "aca_identity" {
  name                = "${var.aca_name}-identity" # Construct a unique name
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

# Grant the ACA's Managed Identity access to get secrets from Key Vault
resource "azurerm_key_vault_access_policy" "aca_kv_access" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id # Assumes client config is available or passed in
  object_id    = azurerm_user_assigned_identity.aca_identity.principal_id

  secret_permissions = [
    "Get",
    "List" # List might be useful for the container app environment in some scenarios
  ]
}

# Data block to get current client config (needed for tenant_id if not passed as var)
data "azurerm_client_config" "current" {}

# Create Azure Container App Environment (ACAE)
resource "azurerm_container_app_environment" "cae" {
  name                = var.aca_env_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  workload_profile {
    name                  = "Consumption" # Or other profile name based on var.workload_profile_type
    workload_profile_type = var.workload_profile_type
    minimum_count         = 0 # For Consumption, usually 0 for scale to zero
    maximum_count         = 1 # For Consumption, can be higher
  }
  # For production, you'd typically integrate this with a VNet
  # dapr_application_insights_connection_string = # Optional
  # log_analytics_workspace_id = # Optional
}

# Create Azure Container App (ACA)
resource "azurerm_container_app" "app" {
  name                         = var.aca_name
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single" # Can be "Multiple" for more advanced scenarios
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  # Secrets block to reference Key Vault secrets
  # The names here ("redis-url", "redis-key") are internal to ACA
  # and will be mapped to environment variables later.
  secret {
    name                = "redis-url" # Internal ACA secret name
    key_vault_secret_id = "${data.azurerm_key_vault.aca_kv.vault_uri}secrets/${var.redis_hostname_secret_name_in_kv}"
    identity            = azurerm_user_assigned_identity.aca_identity.id
  }

  secret {
    name                = "redis-key" # Internal ACA secret name
    key_vault_secret_id = "${data.azurerm_key_vault.aca_kv.vault_uri}secrets/${var.redis_password_secret_name_in_kv}"
    identity            = azurerm_user_assigned_identity.aca_identity.id
  }

  template {
    container {
      name   = var.aca_name # Container name, can be same as app name
      image  = var.docker_image_to_deploy
      cpu    = 0.25    # Example, adjust as per workload_profile_type and needs
      memory = "0.5Gi" # Example

      env {
        name  = "CREATOR"
        value = "ACA"
      }
      env {
        name  = "REDIS_PORT"
        value = "6379" # As per task requirement
      }
      env {
        name        = "REDIS_URL"
        secret_name = "redis-url" # References the ACA internal secret name
      }
      env {
        name        = "REDIS_PWD"
        secret_name = "redis-key" # References the ACA internal secret name
      }
    }

    min_replicas = 0 # For Consumption profile, allow scaling to zero
    max_replicas = 1 # Start with 1, can be increased
  }

  ingress {
    external_enabled = true 
    target_port      = 8080 
    # transport        = "http" 

    traffic_weight { # <--- THIS BLOCK MUST BE PRESENT
      percentage      = 100
      latest_revision = true 
    }
  }

  # Explicit dependency to ensure identity and its permissions are set up first
  depends_on = [
    azurerm_user_assigned_identity.aca_identity,
    azurerm_role_assignment.aca_acr_pull,
    azurerm_key_vault_access_policy.aca_kv_access,
    data.azurerm_key_vault.aca_kv # Ensure KV data source is read
  ]
}

# Data source to get Key Vault details (needed for vault_uri)
data "azurerm_key_vault" "aca_kv" {
  name                = split("/", var.key_vault_id)[8] # Extract KV name from ID
  resource_group_name = var.resource_group_name         # Assuming KV is in same RG
  depends_on = [
    azurerm_key_vault_access_policy.aca_kv_access # Ensure access policy exists before trying to use KV
  ]
}
