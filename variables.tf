variable "docker_host" {
  description = "Docker daemon host"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "local_server_ip" {
  description = "Local server IP address for accessing Kong services"
  type        = string
  default     = "127.0.0.1"
}

variable "kong_db_user" {
  description = "Kong Database username"
  type        = string
  default     = "kong"
}

variable "kong_db_password" {
  description = "Kong Database password"
  type        = string
  sensitive   = true
  default     = "kongpassword"
}

variable "postgres_port" {
  description = "PostgreSQL port exposed"
  type        = number
  default     = 5432
}

variable "kong_proxy_port" {
  description = "Kong Proxy port (HTTP)"
  type        = number
  default     = 8000
}

variable "kong_proxy_ssl_port" {
  description = "Kong Proxy SSL port (HTTPS)"
  type        = number
  default     = 8443
}

variable "kong_admin_port" {
  description = "Kong Admin API port"
  type        = number
  default     = 8001
}

variable "kong_admin_ssl_port" {
  description = "Kong Admin API SSL port"
  type        = number
  default     = 8444
}

variable "kong_manager_port" {
  description = "Kong Manager GUI port"
  type        = number
  default     = 8080
}

variable "volume_mount_path" {
  description = "Path on host for persistent volumes"
  type        = string
  default     = "/tmp/kong-volumes"
}