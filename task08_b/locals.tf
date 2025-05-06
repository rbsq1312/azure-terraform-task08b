locals {
  # Example - Adjust prefix handling as needed
  name_prefix = var.name_prefix # Example: "cmtr-49b8ddc2-mod8b"

  rg_name        = "${local.name_prefix}-rg"
  aci_redis_name = "${local.name_prefix}-redis-ci"            # Changed from redis_aci_name for consistency
  sa_name        = replace("${local.name_prefix}sa", "-", "") # Storage account names have restrictions
  keyvault_name  = "${local.name_prefix}-kv"
  acr_name       = replace("${local.name_prefix}cr", "-", "") # ACR names have restrictions
  aca_env_name   = "${local.name_prefix}-cae"
  aca_name       = "${local.name_prefix}-ca"
  aks_name       = "${local.name_prefix}-aks"

  common_tags = {
    Creator = var.creator
  }

  # Docker image details
  docker_image_name = "${local.name_prefix}-app"
  docker_image_tag  = "latest" # Or use a dynamic tag if needed

  # Storage Account details
  storage_container_name = "app-content"
  storage_blob_name      = "app.tar.gz" # Name for the archived blob

  # Default secret names for Redis module to create/use
  redis_hostname_secret_name = "redis-hostname"
  redis_password_secret_name = "redis-password" # Changed from primary-key as it's random now
}
