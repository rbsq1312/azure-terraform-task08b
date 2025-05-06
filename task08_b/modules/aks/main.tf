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
    os_disk_size_gb = var.default_node_pool_os_disk_size_gb # Critical for Ephemeral + D2ads_v5
    os_sku          = "Ubuntu"                              # Common default, adjust if your image needs Mariner etc.
    # type            = "VirtualMachineScaleSets" # Usually default
  }

  identity {
    type = "SystemAssigned"
  }

  # Enable the Azure Key Vault Secrets Provider for CSI driver
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "5m" # Or your desired interval
  }

  # Add other necessary configurations like network_profile if needed
  # For example, if your ACI Redis is on a VNet, AKS might need to be on the same VNet or peered.
  # network_profile {
  #   network_plugin = "azure"
  #   service_cidr   = "10.0.0.0/16"
  #   dns_service_ip = "10.0.0.10"
  #   docker_bridge_cidr = "172.17.0.1/16"
  # }
}

# Grant AKS Kubelet Identity access to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true # Required for managed identities
}

# Grant AKS Key Vault CSI Driver Identity access to get secrets from Key Vault
resource "azurerm_key_vault_access_policy" "aks_csi_kv_access" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id

  secret_permissions = [
    "Get", "List" # List might be needed by some CSI driver versions or for broader functionality
  ]
}
