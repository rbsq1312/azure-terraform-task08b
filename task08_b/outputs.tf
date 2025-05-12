output "redis_fqdn" {
  description = "FQDN of Redis in Azure Container Instance"
  value       = module.aci_redis.redis_ip_address // CHANGED: was module.aci_redis.redis_fqdn
}

output "aca_fqdn" {
  description = "FQDN of App in Azure Container App"
  value       = module.aca.aca_fqdn
}

output "aks_lb_ip" {
  description = "Load Balancer IP address of APP in AKS"
  value       = module.k8s.service_load_balancer_ingress_ip
}
