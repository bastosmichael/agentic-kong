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

  depends_on = [
    docker_container.kong_db,
    docker_container.kong_migration
  ]

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
    "KONG_ADMIN_LISTEN=0.0.0.0:8001",
    "KONG_ADMIN_GUI_LISTEN=0.0.0.0:8002",
    "KONG_ADMIN_GUI_URL=http://${var.local_server_ip}:${var.kong_manager_port}"
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

  ports {
    internal = 8002
    external = var.kong_manager_port
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

resource "null_resource" "kong_config" {
  depends_on = [docker_container.kong_gateway]

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/setup-kong-config.sh http://${var.local_server_ip}:${var.kong_admin_port}"
  }
}
