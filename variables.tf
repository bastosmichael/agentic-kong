variable "docker_host" {
  description = "Docker host socket or URL"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "local_server_ip" {
  description = "Local server IP address for accessing Kong services"
  type        = string
}

variable "kong_db_user" {
  description = "Kong database username"
  type        = string
  sensitive   = true
}

variable "kong_db_password" {
  description = "Kong database password"
  type        = string
  sensitive   = true
}

variable "postgres_port" {
  description = "PostgreSQL port on the host machine"
  type        = number
  default     = 5432
}

variable "kong_proxy_port" {
  description = "Kong proxy HTTP port on the host machine"
  type        = number
  default     = 8000
}

variable "kong_proxy_ssl_port" {
  description = "Kong proxy HTTPS port on the host machine"
  type        = number
  default     = 8443
}

variable "kong_admin_port" {
  description = "Kong admin API HTTP port on the host machine"
  type        = number
  default     = 8001
}

variable "kong_admin_ssl_port" {
  description = "Kong admin API HTTPS port on the host machine"
  type        = number
  default     = 8444
}

variable "kong_manager_port" {
  description = "Kong Manager GUI port on the host machine"
  type        = number
  default     = 8002
}

variable "volume_mount_path" {
  description = "Host path for volume mounts"
  type        = string
  default     = "/tmp/kong-volumes"
}
