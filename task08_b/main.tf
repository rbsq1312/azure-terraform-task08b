# Root main.tf - Orchestrates module deployment

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = local.common_tags
}

# Placeholder module calls - Add inputs/outputs/dependencies later
module "keyvault" {
  source = "./modules/keyvault"
  # Add required variables: resource_group_name, location, key_vault_name, key_vault_sku, tags, tenant_id, current_user_object_id
}

module "aci_redis" {
  source = "./modules/aci_redis"
  # Add required variables: resource_group_name, location, aci_redis_name, aci_sku, tags, key_vault_id, redis_hostname_secret_name, redis_password_secret_name
  # depends_on = [module.keyvault] # Likely dependency
}

module "storage" {
  source = "./modules/storage"
  # Add required variables: resource_group_name, location, sa_name, sa_replication_type, storage_container_name, storage_blob_name, source_content_path, tags
}

module "acr" {
  source = "./modules/acr"
  # Add required variables: resource_group_name, location, acr_name, acr_sku, tags, docker_image_name, build_context_path (blob url), build_context_token (sas)
  # depends_on = [module.storage] # Likely dependency
}

module "aks" {
  source = "./modules/aks"
  # Add required variables: resource_group_name, location, aks_name, tags, dns_prefix, node_pool_name, node_count, vm_size, os_disk_type, default_node_pool_os_disk_size_gb, acr_id, key_vault_id, tenant_id, key_vault_name
  # depends_on = [module.acr, module.keyvault] # Likely dependencies
}

module "aca" {
  source = "./modules/aca"
 # Add required variables: resource_group_name, location, aca_name, aca_env_name, tags, workload_profile_type, docker_image_full_name, acr_id, key_vault_id, redis_hostname_secret_name, redis_password_secret_name
 # depends_on = [module.acr, module.keyvault, module.aci_redis] # Likely dependencies
}

module "k8s" {
 source = "./modules/k8s"
 # Add required variables: acr_login_server, app_image_name, image_tag, key_vault_name, redis_hostname_secret_name, redis_password_secret_name, tenant_id, aks_kv_identity_client_id
 # depends_on = [module.aks, module.keyvault, module.aci_redis] # Likely dependencies
}

# Add time_sleep and data source for K8s service IP if needed for output
# resource "time_sleep" "wait_for_lb_ip" { ... }
# data "kubernetes_service" "app" { ... depends_on = [time_sleep.wait_for_lb_ip] }

