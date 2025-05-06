data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = local.common_tags
}

# Placeholder module calls - Add inputs/outputs/dependencies later
module "keyvault" {
  source = "./modules/keyvault" # Path to your keyvault module

  key_vault_name         = local.keyvault_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  key_vault_sku          = "standard" # As per task parameters (or use a root variable if you prefer)
  tags                   = local.common_tags
  tenant_id              = data.azurerm_client_config.current.tenant_id
  current_user_object_id = data.azurerm_client_config.current.object_id # For initial access policy
}

module "aci_redis" {
  source = "./modules/aci_redis"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.common_tags

  aci_redis_name = local.aci_redis_name # From root locals.tf
  aci_sku        = var.aci_sku          # From root variables.tf

  key_vault_id               = module.keyvault.key_vault_id     # Output from keyvault module
  redis_hostname_secret_name = local.redis_hostname_secret_name # From root locals.tf
  redis_password_secret_name = local.redis_password_secret_name # From root locals.tf

  depends_on = [
    module.keyvault # Ensure Key Vault is created before trying to store secrets in it
  ]
}

module "storage" {
  source = "./modules/storage" # Path to your storage module

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.common_tags

  storage_account_name             = local.sa_name                        # From your root locals.tf
  storage_account_replication_type = var.storage_account_replication_type # From your root variables.tf
  storage_container_name           = local.storage_container_name         # From your root locals.tf
  storage_blob_name                = local.storage_blob_name              # From your root locals.tf

  # Path to the application directory to be archived.
  # This path is relative to the root task08_b directory where you run 'terraform apply'.
  source_content_path = "./application"
}

resource "time_static" "sas_start_time" {
  # This ensures the start time is fixed for the duration of the apply
}

resource "time_offset" "sas_expiry_time" {
  offset_hours = 1 # SAS token valid for 1 hour
  base_rfc3339 = time_static.sas_start_time.rfc3339
}

data "azurerm_storage_account_blob_container_sas" "app_content_sas" {
  connection_string = module.storage.storage_account_primary_connection_string # Assuming storage module outputs this
  container_name    = module.storage.storage_container_name

  start  = time_static.sas_start_time.rfc3339
  expiry = time_offset.sas_expiry_time.rfc3339

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false # ACR Task needs to read the blob, not list the container
  }

  depends_on = [module.storage] # Ensure storage account and container exist
}


module "acr" {
  source = "./modules/acr" # Path to your acr module

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.common_tags

  acr_name          = local.acr_name          # From root locals.tf
  acr_sku           = var.acr_sku             # From root variables.tf
  docker_image_name = local.docker_image_name # From root locals.tf (e.g., cmtr-49b8ddc2-mod8b-app)

  # Inputs for building from blob
  acr_task_build_context_blob_url  = module.storage.storage_blob_url
  acr_task_build_context_sas_token = data.azurerm_storage_account_blob_container_sas.app_content_sas.sas

  depends_on = [
    module.storage,
    data.azurerm_storage_account_blob_container_sas.app_content_sas # Ensure SAS is ready
  ]
}

module "aks" {
  source = "./modules/aks" # Path to your aks module

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.common_tags

  aks_name                          = local.aks_name                        # From root locals.tf
  dns_prefix                        = local.aks_name                        # Using aks_name as dns_prefix as per previous task
  node_pool_name                    = var.aks_node_pool_name                # From root variables.tf
  node_count                        = var.aks_node_count                    # From root variables.tf
  vm_size                           = var.aks_vm_size                       # From root variables.tf (should be D2ads_v5)
  os_disk_type                      = var.aks_os_disk_type                  # From root variables.tf (should be Ephemeral)
  default_node_pool_os_disk_size_gb = var.default_node_pool_os_disk_size_gb # From root variables.tf (default 60)

  acr_id       = module.acr.acr_id                            # Output from acr module
  key_vault_id = module.keyvault.key_vault_id                 # Output from keyvault module
  tenant_id    = data.azurerm_client_config.current.tenant_id # From data source

  depends_on = [
    module.acr,     # AKS needs ACR to be ready for image pulls
    module.keyvault # AKS needs Key Vault for CSI driver integration
  ]
}

module "aca" {
  source = "./modules/aca" # Path to your aca module

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.common_tags

  aca_env_name          = local.aca_env_name            # From root locals.tf
  aca_name              = local.aca_name                # From root locals.tf
  workload_profile_type = var.aca_workload_profile_type # From root variables.tf

  docker_image_to_deploy = module.acr.docker_image_full_name_latest # Output from acr module
  acr_id                 = module.acr.acr_id                        # Output from acr module
  # acr_login_server       = module.acr.acr_login_server # Not explicitly needed by module if using managed identity for pull

  key_vault_id                     = module.keyvault.key_vault_id     # Output from keyvault module
  redis_hostname_secret_name_in_kv = local.redis_hostname_secret_name # From root locals.tf
  redis_password_secret_name_in_kv = local.redis_password_secret_name # From root locals.tf

  depends_on = [
    module.acr,      # ACA needs the image to be built and ACR to exist
    module.keyvault, # ACA needs Key Vault for secrets
    module.aci_redis # ACA needs Redis hostname/password secrets to be in Key Vault
  ]
}

module "k8s" {
  source = "./modules/k8s"

  providers = {
    kubectl    = kubectl.k8s_config
    kubernetes = kubernetes.k8s_config
  }

  acr_login_server                 = module.acr.acr_login_server
  app_image_name                   = local.docker_image_name # From root locals.tf
  image_tag                        = local.docker_image_tag  # From root locals.tf
  key_vault_name                   = module.keyvault.key_vault_name
  redis_hostname_secret_name_in_kv = local.redis_hostname_secret_name # From root locals.tf
  redis_password_secret_name_in_kv = local.redis_password_secret_name # From root locals.tf
  tenant_id                        = data.azurerm_client_config.current.tenant_id
  aks_kv_identity_client_id        = module.aks.aks_kv_identity_client_id # Output from AKS module

  depends_on = [
    module.aks,       # K8s resources depend on AKS cluster being ready
    module.aci_redis, # For Redis secrets being available in KV
    module.acr        # For the image being available
  ]
}
# Add time_sleep and data source for K8s service IP if needed for output
# resource "time_sleep" "wait_for_lb_ip" { ... }
# data "kubernetes_service" "app" { ... depends_on = [time_sleep.wait_for_lb_ip] }

