output "redis_fqdn" {
  description = "FQDN of Redis in Azure Container Instance"
  value       = module.aci_redis.redis_fqdn # Assuming module outputs this
}

output "aca_fqdn" {
  description = "FQDN of App in Azure Container App"
  value       = module.aca.aca_fqdn # Assuming module outputs this
}

output "aks_lb_ip" {
  description = "Load Balancer IP address of APP in AKS"
  # Needs careful handling - use time_sleep + direct access OR try()
  # Example using time_sleep (requires data source named 'app' in main.tf)
  # value       = data.kubernetes_service.app.status[0].load_balancer[0].ingress[0].ip 
  # Example using try() (assuming data source named 'app_service' in main.tf)
  # value       = try(data.kubernetes_service.app_service.status[0].load_balancer[0].ingress[0].ip, "Pending...")
  value       = "Placeholder - Configure based on chosen wait strategy"
}
