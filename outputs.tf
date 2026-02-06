output "kong_admin_url" {
  value       = "http://<KONG_ADMIN_HOST>:<KONG_ADMIN_PORT>"
  description = "The URL of the Kong Admin API for managing services and routes."
}

output "kong_proxy_url" {
  value       = "http://<KONG_PROXY_HOST>:<KONG_PROXY_PORT>"
  description = "The URL of the Kong Proxy for routing client requests."
}

output "service_id" {
  value       = "<SERVICE_ID>"
  description = "The ID of the service that you have created in Kong."
}

output "route_id" {
  value       = "<ROUTE_ID>"
  description = "The ID of the route that maps to your service in Kong."
}

output "consumer_id" {
  value       = "<CONSUMER_ID>"
  description = "The ID of the consumer that interacts with the Kong services."
}
