# In modules/k8s/main.tf

resource "kubectl_manifest" "secret_provider_class" {
  # Provider alias will be passed from the root module if needed
  # provider = kubectl.k8s_config 

  yaml_body = templatefile("${path.module}/../../k8s-manifests/secret-provider.yaml.tftpl", {
    kv_name                    = var.key_vault_name
    redis_url_secret_name      = var.redis_hostname_secret_name_in_kv
    redis_password_secret_name = var.redis_password_secret_name_in_kv
    tenant_id                  = var.tenant_id
    aks_kv_access_identity_id  = var.aks_kv_identity_client_id
  })
}

resource "kubectl_manifest" "service" {
  # provider = kubectl.k8s_config

  yaml_body = file("${path.module}/../../k8s-manifests/service.yaml")

  depends_on = [
    kubectl_manifest.secret_provider_class
  ]
}

resource "kubectl_manifest" "deployment" {
  # provider = kubectl.k8s_config

  yaml_body = templatefile("${path.module}/../../k8s-manifests/deployment.yaml.tftpl", {
    acr_login_server = var.acr_login_server
    app_image_name   = var.app_image_name
    image_tag        = var.image_tag
  })

  wait_for_rollout = false

  depends_on = [
    kubectl_manifest.service
  ]
}

# Add time_sleep here
resource "time_sleep" "wait_for_k8s_lb_ip" {
  create_duration = "5m" # Or your preferred duration

  depends_on = [
    kubectl_manifest.service # Wait after the service is applied
  ]
}

# Data source to access information about deployed Kubernetes service
data "kubernetes_service" "app_service_data" {
  # provider = kubernetes.k8s_config

  metadata {
    name      = "redis-flask-app-service"
    namespace = "default"
  }

  depends_on = [
    # Ensure data is read AFTER the sleep
    time_sleep.wait_for_k8s_lb_ip
  ]
}
