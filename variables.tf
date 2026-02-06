# Terraform Variables for Kong Deployment

variable "kong_admin_url" {
  description = "The URL for the Kong Admin API"
  type        = string
}

variable "database_url" {
  description = "The database connection string"
  type        = string
}

variable "kong_consumer" {
  description = "The Kong consumer name"
  type        = string
}

variable "service_name" {
  description = "The name of the service to be deployed"
  type        = string
}

variable "service_url" {
  description = "The URL of the service"
  type        = string
}

variable "route_paths" {
  description = "The paths that route to the service"
  type        = list(string)
}

variable "enable_tls" {
  description = "Enable TLS for the service"
  type        = bool
}

# Additional variables can be defined based on your requirements
