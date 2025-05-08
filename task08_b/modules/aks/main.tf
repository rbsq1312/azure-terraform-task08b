# Create a User-Assigned Managed Identity for AKS Key Vault integration
resource "azurerm_user_assigned_identity" "aks_kv_identity" {
  name                = "${var.aks_name}-kv-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  tags                = var.tags

  default_node_pool {
    name            = var.node_pool_name
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_type    = var.os_disk_type
    os_disk_size_gb = var.default_node_pool_os_disk_size_gb
    os_sku          = "Ubuntu"
  }

  identity {
    type = "SystemAssigned"
  }

  # Configure Key Vault Secrets Provider with User-Assigned Identity
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "5m"
    secret_identity {
      user_assigned_identity_id = azurerm_user_assigned_identity.aks_kv_identity.id
    }
  }
}

# Grant AKS Kubelet Identity access to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}

# Grant the User-Assigned Identity access to Key Vault
resource "azurerm_key_vault_access_policy" "aks_csi_kv_access" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.aks_kv_identity.principal_id

  secret_permissions = [
    "Get", "List"
  ]
}
