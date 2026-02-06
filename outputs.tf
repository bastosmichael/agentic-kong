output "kong_gateway_url" {
  description = "Kong Gateway Proxy URL"
  value       = "http://${var.local_server_ip}:${var.kong_proxy_port}"
}

output "kong_admin_api_url" {
  description = "Kong Admin API URL"
  value       = "http://${var.local_server_ip}:${var.kong_admin_port}"
}

output "kong_manager_url" {
  description = "Kong Manager GUI URL"
  value       = "http://${var.local_server_ip}:${var.kong_manager_port}"
}

output "database_host" {
  description = "Database Host"
  value       = docker_container.kong_db.hostname
}
