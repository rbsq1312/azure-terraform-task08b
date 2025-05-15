# Generate a random password for Redis
resource "random_password" "redis_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  upper            = true
  lower            = true
  numeric          = true
}

# Create Azure Container Instance for Redis
resource "azurerm_container_group" "redis_ci" {
  name                = var.aci_redis_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public"
  os_type             = "Linux"
  sku                 = var.aci_sku
  tags                = var.tags
  dns_name_label      = "${var.aci_redis_name}-dns"

  container {
    name   = "redis"
    image  = "mcr.microsoft.com/cbl-mariner/base/redis:6.2"
    cpu    = 1.0
    memory = 1.5

    ports {
      port     = 6379
      protocol = "TCP"
    }

    commands = [
      "redis-server",
      "--requirepass", random_password.redis_password.result,
      "--protected-mode", "no"
    ]
  }
}

# Wait for Redis to initialize
resource "time_sleep" "wait_for_redis" {
  depends_on      = [azurerm_container_group.redis_ci]
  create_duration = "3m"
}

# Store the Redis ACI FQDN in Key Vault
resource "azurerm_key_vault_secret" "redis_hostname" {
  name         = var.redis_hostname_secret_name
  value        = "${azurerm_container_group.redis_ci.fqdn}:6379"
  key_vault_id = var.key_vault_id
  tags         = var.tags
  depends_on   = [time_sleep.wait_for_redis]
}

# Store the generated Redis password in Key Vault
resource "azurerm_key_vault_secret" "redis_password" {
  name         = var.redis_password_secret_name
  value        = random_password.redis_password.result
  key_vault_id = var.key_vault_id
  tags         = var.tags
  depends_on   = [time_sleep.wait_for_redis]
}
