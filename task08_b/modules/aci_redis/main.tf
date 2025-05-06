# Generate a random password for Redis
resource "random_password" "redis_password" {
  length           = 24 # Task requires at least 16, 24 is good
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?" # Define allowed special characters
  upper            = true
  lower            = true
  numeric          = true
}

# Create Azure Container Instance for Redis
resource "azurerm_container_group" "redis_ci" {
  name                = var.aci_redis_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public" # For simplicity, can be Private if VNet integrated
  os_type             = "Linux"
  sku                 = var.aci_sku
  tags                = var.tags

  container {
    name = "redis"
    # Using official Redis image from Microsoft Artifact Registry (MCR)
    image  = "mcr.microsoft.com/azure-cache/redis:latest" # Or a specific version like :7.2
    cpu    = 1.0                                          # Adjust as needed
    memory = 1.5                                          # Adjust as needed
    ports {
      port     = 6379
      protocol = "TCP"
    }
    # Start Redis server with the generated password and allow external connections (no protected mode)
    # Note: For production, carefully consider security implications of disabling protected mode.
    # If ACI is VNet integrated and accessed only privately, this is safer.
    commands = [
      "redis-server",
      "--requirepass", random_password.redis_password.result,
      "--protected-mode", "no" # Required if not binding to localhost and no password set, or for easier access from other services
    ]
  }

  # Optional: VNet integration if needed for AKS/ACA to reach Redis privately
  # dynamic "network_profile" {
  #   for_each = var.subnet_ids != null ? [1] : []
  #   content {
  #     id = var.subnet_ids[0] # Assuming one subnet for simplicity
  #   }
  # }
}

# Store the Redis ACI FQDN (hostname) in Key Vault
resource "azurerm_key_vault_secret" "redis_hostname" {
  name         = var.redis_hostname_secret_name
  value        = azurerm_container_group.redis_ci.fqdn # Use FQDN if public, IP if private/VNet
  key_vault_id = var.key_vault_id

  tags       = var.tags
  depends_on = [azurerm_container_group.redis_ci] # Ensure ACI is created first
}

# Store the generated Redis password in Key Vault
resource "azurerm_key_vault_secret" "redis_password" {
  name         = var.redis_password_secret_name
  value        = random_password.redis_password.result
  key_vault_id = var.key_vault_id

  tags = var.tags
  # depends_on implicitly on random_password, explicitly on ACI to group secret creation
  depends_on = [azurerm_container_group.redis_ci]
}
