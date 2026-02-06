terraform {
  required_version = ">= 1.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = var.docker_host
}

# Kong Database (PostgreSQL)
resource "docker_image" "postgres" {
  name          = "postgres:15-alpine"
  keep_locally  = false
  pull_image    = true
}

resource "docker_container" "kong_db" {
  name  = "kong-database"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_DB=kong",
    "POSTGRES_USER=${var.kong_db_user}",
    "POSTGRES_PASSWORD=${var.kong_db_password}"
  ]

  ports {
    internal = 5432
    external = var.postgres_port
  }

  volumes {
    host_path      = "${var.volume_mount_path}/kong_db_data"
    container_path = "/var/lib/postgresql/data"
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U ${var.kong_db_user}"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }

  restart_policy = "always"
}

# Kong Gateway
resource "docker_image" "kong" {
  name          = "kong:3.4-alpine"
  keep_locally  = false
  pull_image    = true
}

resource "docker_container" "kong_gateway" {
  name  = "kong-gateway"
  image = docker_image.kong.image_id

  depends_on = [docker_container.kong_db]

  env = [
    "KONG_DATABASE=postgres",
    "KONG_PG_HOST=${docker_container.kong_db.hostname}",
    "KONG_PG_PORT=5432",
    "KONG_PG_USER=${var.kong_db_user}",
    "KONG_PG_PASSWORD=${var.kong_db_password}",
    "KONG_PROXY_ACCESS_LOG=/dev/stdout",
    "KONG_ADMIN_ACCESS_LOG=/dev/stdout",
    "KONG_PROXY_ERROR_LOG=/dev/stderr",
    "KONG_ADMIN_ERROR_LOG=/dev/stderr",
    "KONG_ADMIN_LISTEN=0.0.0.0:8001"
  ]

  ports {
    internal = 8000
    external = var.kong_proxy_port
  }

  ports {
    internal = 8443
    external = var.kong_proxy_ssl_port
  }

  ports {
    internal = 8001
    external = var.kong_admin_port
  }

  ports {
    internal = 8444
    external = var.kong_admin_ssl_port
  }

  healthcheck {
    test     = ["CMD", "kong", "health"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }

  restart_policy = "always"
}

# Run Kong DB Migration
resource "docker_container" "kong_migration" {
  name              = "kong-migration"
  image             = docker_image.kong.image_id
  rm                = true
  must_run          = false
  
  depends_on        = [docker_container.kong_db]

  env = [
    "KONG_DATABASE=postgres",
    "KONG_PG_HOST=${docker_container.kong_db.hostname}",
    "KONG_PG_PORT=5432",
    "KONG_PG_USER=${var.kong_db_user}",
    "KONG_PG_PASSWORD=${var.kong_db_password}",
  ]

  command = ["kong", "migrations", "bootstrap"]
}

# Kong Manager (Optional - GUI for Kong)
resource "docker_image" "kong_manager" {
  name          = "node:18-alpine"
  keep_locally  = false
  pull_image    = true
}

resource "docker_container" "kong_manager" {
  name  = "kong-manager"
  image = docker_image.kong_manager.image_id

  depends_on = [docker_container.kong_gateway]

  ports {
    internal = 8080
    external = var.kong_manager_port
  }

  volumes {
    host_path      = "${path.module}/kong-manager"
    container_path = "/app"
  }

  working_dir = "/app"
  command     = ["npm", "start"]

  env = [
    "KONG_ADMIN_URL=http://${var.local_server_ip}:${var.kong_admin_port}",
    "PORT=8080"
  ]

  restart_policy = "always"
}

# Output Kong Gateway URLs
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