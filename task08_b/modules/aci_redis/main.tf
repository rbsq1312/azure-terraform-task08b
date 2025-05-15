data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = local.common_tags
}

module "keyvault" {
  source = "./modules/keyvault"

  key_vault_name         = local.keyvault_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  key_vault_sku          = "standard"
  tags                   = local.common_tags
  tenant_id              = data.azurerm_client_config.current.tenant_id
  current_user_object_id = data.azurerm_client_config.current.object_id
}

module "aci_redis" {
  source = "./modules/aci_redis"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.common_tags

  aci_redis_name = local.aci_redis_name
  aci_sku        = var.aci_sku

  key_vault_id               = module.keyvault.key_vault_id
  redis_hostname_secret_name = local.redis_hostname_secret_name
  redis_password_secret_name = local.redis_password_secret_name

  depends_on = [
    module.keyvault
  ]
}

module "storage" {
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.common_tags

  storage_account_name             = local.sa_name
  storage_account_replication_type = var.storage_account_replication_type
  storage_container_name           = local.storage_container_name
  storage_blob_name                = local.storage_blob_name
  source_content_path              = "./application"
}

resource "time_static" "sas_start_time" {
}

resource "time_offset" "sas_expiry_time" {
  offset_hours = 1
  base_rfc3339 = time_static.sas_start_time.rfc3339
}

data "azurerm_storage_account_blob_container_sas" "app_content_sas" {
  connection_string = module.storage.storage_account_primary_connection_string
  container_name    = module.storage.storage_container_name

  start  = time_static.sas_start_time.rfc3339
  expiry = time_offset.sas_expiry_time.rfc3339

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }

  depends_on = [module.storage]
}

module "acr" {
  source = "./modules/acr"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.common_tags

  acr_name          = local.acr_name
  acr_sku           = var.acr_sku
  docker_image_name = local.docker_image_name

  acr_task_build_context_blob_url  = module.storage.storage_blob_url
  acr_task_build_context_sas_token = data.azurerm_storage_account_blob_container_sas.app_content_sas.sas

  depends_on = [
    module.storage,
    data.azurerm_storage_account_blob_container_sas.app_content_sas
  ]
}

module "aks" {
  source = "./modules/aks"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.common_tags

  aks_name                          = local.aks_name
  dns_prefix                        = local.aks_name
  node_pool_name                    = var.aks_node_pool_name
  node_count                        = var.aks_node_count
  vm_size                           = var.aks_vm_size
  os_disk_type                      = var.aks_os_disk_type
  default_node_pool_os_disk_size_gb = var.default_node_pool_os_disk_size_gb

  acr_id       = module.acr.acr_id
  key_vault_id = module.keyvault.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  depends_on = [
    module.acr,
    module.keyvault
  ]
}

resource "time_sleep" "wait_for_redis_aca_propagation" {
  depends_on      = [module.aci_redis]
  create_duration = "3m"
}

module "aca" {
  source = "./modules/aca"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.common_tags

  name             = local.aca_name
  environment_name = local.aca_env_name

  registry_server = module.acr.acr_login_server
  image_name      = local.docker_image_name
  image_tag       = local.docker_image_tag

  tenant_id = data.azurerm_client_config.current.tenant_id
  acr_id    = module.acr.acr_id

  key_vault_id              = module.keyvault.key_vault_id
  redis_hostname_secret_uri = "${module.keyvault.key_vault_uri}secrets/${local.redis_hostname_secret_name}"
  redis_password_secret_uri = "${module.keyvault.key_vault_uri}secrets/${local.redis_password_secret_name}"

  depends_on = [
    module.acr,
    module.keyvault,
    module.aci_redis,
    time_sleep.wait_for_redis_aca_propagation
  ]
}

resource "time_sleep" "wait_for_redis_propagation" {
  depends_on      = [module.aci_redis]
  create_duration = "2m"
}

module "k8s" {
  source = "./modules/k8s"

  providers = {
    kubectl    = kubectl.k8s_config
    kubernetes = kubernetes.k8s_config
  }

  acr_login_server                 = module.acr.acr_login_server
  app_image_name                   = local.docker_image_name
  image_tag                        = local.docker_image_tag
  key_vault_name                   = module.keyvault.key_vault_name
  redis_hostname_secret_name_in_kv = local.redis_hostname_secret_name
  redis_password_secret_name_in_kv = local.redis_password_secret_name
  tenant_id                        = data.azurerm_client_config.current.tenant_id
  aks_kv_identity_client_id        = module.aks.aks_kv_identity_client_id

  depends_on = [
    module.aks,
    module.aci_redis,
    module.acr,
    time_sleep.wait_for_redis_propagation
  ]
}
