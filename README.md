# Kong OpenAI Mock Terraform Deployment

This repo deploys Kong Gateway, PostgreSQL, and a preconfigured mock of the OpenAI API v1 using Terraform + Docker. The mock endpoints return static JSON so you can demo AI-style calls locally.

## Quick start

1. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Update `local_server_ip` with the IP of the machine running Docker.
3. Apply:
   ```bash
   terraform init
   terraform apply
   ```

Terraform will start Kong, run database migrations, and apply the mock API configuration.

## Endpoints (mocked)

Base proxy URL:
```
http://<local_server_ip>:8000
```

Mocked endpoints (all require `apikey: demo-openai-key` by default):

- `GET /v1/models`
- `POST /v1/chat/completions`
- `POST /v1/completions`
- `POST /v1/embeddings`

Example:
```bash
curl -sS http://<local_server_ip>:8000/v1/chat/completions \
  -H "apikey: demo-openai-key" \
  -H "content-type: application/json" \
  -d '{"model":"gpt-4.1-mini","messages":[{"role":"user","content":"Hello!"}]}'
```

## Kong Manager (Admin GUI)

Kong Manager is exposed from the Kong container:

```
http://<local_server_ip>:8002
```

Use the Admin GUI to:
- Add new consumers and API keys for users.
- Enable/disable logging plugins.
- Inspect configured services, routes, and plugins.

## Usage logging

The mock service enables the `file-log` plugin with `config.path=/dev/stdout`, so gateway usage is visible in container logs. You can disable or change logging from Kong Manager or via the Admin API.

## Admin API

```
http://<local_server_ip>:8001
```

You can use the Admin API to customize plugins, add consumers, or change routing.
