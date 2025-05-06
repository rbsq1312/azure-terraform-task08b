resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = true # Often useful, especially for ACI if not using managed identity
  tags                = var.tags
}

resource "azurerm_container_registry_task" "app_build_task" {
  name                  = "${var.docker_image_name}-build-task-from-blob"
  container_registry_id = azurerm_container_registry.acr.id
  platform {
    os = "Linux"
  }

  # The build context is the blob URL, and the context_path within the extracted archive for Dockerfile
  # The SAS token provides access
  docker_step {
    dockerfile_path      = "Dockerfile" # Path to Dockerfile INSIDE the tar.gz archive
    image_names          = ["${var.docker_image_name}:latest", "${var.docker_image_name}:{{.Run.ID}}"]
    context_path         = var.acr_task_build_context_blob_url  # This is the URL of the tar.gz blob
    context_access_token = var.acr_task_build_context_sas_token # The SAS token
  }

  # No source_trigger from Git, as we are building from blob
  # If you still want a Git trigger for other purposes, it can be added.

  # Using an agent pool might be needed for more complex or frequent builds in production
  # agent_pool_name = "default" 

  timeout_in_seconds = 3600 # 1 hour build timeout for the task definition
}

# Schedule an immediate run of the task
resource "azurerm_container_registry_task_schedule_run_now" "schedule_run_blob" {
  container_registry_task_id = azurerm_container_registry_task.app_build_task.id

  timeouts {
    create = "15m" # How long Terraform waits for THIS schedule_run to complete
  }
}
