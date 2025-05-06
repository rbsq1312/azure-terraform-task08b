output "service_name" {
  description = "The name of the deployed Kubernetes service."
  value       = data.kubernetes_service.app_service_data.metadata[0].name
}

output "service_cluster_ip" {
  description = "The cluster IP of the deployed Kubernetes service."
  value       = try(data.kubernetes_service.app_service_data.spec[0].cluster_ip, "Pending...")
}

output "service_load_balancer_ingress_ip" {
  description = "The Load Balancer Ingress IP for the service."
  value       = try(data.kubernetes_service.app_service_data.status[0].load_balancer[0].ingress[0].ip, "Pending...")
}
