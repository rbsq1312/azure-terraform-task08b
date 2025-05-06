output "aks_id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_name" {
  description = "The Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kube_config_raw" {
  description = "Raw Kubeconfig for the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "host" {
  description = "The FQDN of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate for authenticating to the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Client key for authenticating to the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate for authenticating to the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

output "aks_kv_identity_client_id" {
  description = "The Client ID of the Managed Identity used by AKS Key Vault CSI driver."
  # Important: For SystemAssigned identity on key_vault_secrets_provider,
  # the secret_identity block contains object_id and user_assigned_identity_id.
  # If using SystemAssigned, the client_id is not directly available here for Role Assignments/Access Policies.
  # The object_id is used for permissions. If a specific client_id is needed for other purposes,
  # you might need to use a User Assigned Identity or query it differently.
  # For the k8s secret-provider.yaml.tftpl's 'userAssignedIdentityID' field, it actually expects the Client ID of a User Assigned Identity.
  # If using SystemAssigned for CSI, this output might not be what k8s manifest expects if it's looking for a UAMI client ID.
  # Let's assume for now the CSI driver's system identity object_id is what's needed for the access policy,
  # and the k8s manifest might need adjustment or a User Assigned Identity if it strictly needs a ClientID.
  # For simplicity and based on the access policy using object_id, let's output the object_id.
  # If your k8s manifest *requires* a client_id, you should create a User Assigned Identity and assign it to AKS.
  value = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id
  # If you were using a user_assigned_identity for key_vault_secrets_provider, you'd output its client_id.
}
