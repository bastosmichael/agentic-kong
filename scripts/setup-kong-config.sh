#!/bin/bash

set -euo pipefail

ADMIN_URL="${1:-http://localhost:8001}"

wait_for_kong() {
  echo "Waiting for Kong Admin API at ${ADMIN_URL}..."
  for _ in {1..30}; do
    if curl -sSf "${ADMIN_URL}/status" >/dev/null; then
      echo "Kong Admin API is ready."
      return 0
    fi
    sleep 2
  done

  echo "Timed out waiting for Kong Admin API."
  return 1
}

create_service() {
  curl -sSf -X POST "${ADMIN_URL}/services" \
    --data 'name=openai-mock' \
    --data 'url=http://mock.invalid' >/dev/null || true
}

create_route() {
  local route_name="$1"
  local path="$2"

  curl -sSf -X POST "${ADMIN_URL}/services/openai-mock/routes" \
    --data "name=${route_name}" \
    --data "paths[]=${path}" >/dev/null || true
}

add_request_termination() {
  local route_name="$1"
  local body="$2"

  curl -sSf -X POST "${ADMIN_URL}/routes/${route_name}/plugins" \
    --data 'name=request-termination' \
    --data 'config.status_code=200' \
    --data 'config.content_type=application/json' \
    --data-urlencode "config.body=${body}" >/dev/null || true
}

add_file_log() {
  curl -sSf -X POST "${ADMIN_URL}/services/openai-mock/plugins" \
    --data 'name=file-log' \
    --data 'config.path=/dev/stdout' >/dev/null || true
}

add_key_auth() {
  curl -sSf -X POST "${ADMIN_URL}/services/openai-mock/plugins" \
    --data 'name=key-auth' >/dev/null || true

  curl -sSf -X POST "${ADMIN_URL}/consumers" \
    --data 'username=demo-user' >/dev/null || true

  curl -sSf -X POST "${ADMIN_URL}/consumers/demo-user/key-auth" \
    --data 'key=demo-openai-key' >/dev/null || true
}

wait_for_kong
create_service

create_route "openai-models" "/v1/models"
create_route "openai-chat-completions" "/v1/chat/completions"
create_route "openai-completions" "/v1/completions"
create_route "openai-embeddings" "/v1/embeddings"

add_request_termination "openai-models" '{"data":[{"id":"gpt-4.1-mini","object":"model","created":1728000000,"owned_by":"openai-mock"}],"object":"list"}'
add_request_termination "openai-chat-completions" '{"id":"chatcmpl-mock","object":"chat.completion","created":1728000001,"model":"gpt-4.1-mini","choices":[{"index":0,"message":{"role":"assistant","content":"This is a mocked response from Kong Gateway."},"finish_reason":"stop"}],"usage":{"prompt_tokens":12,"completion_tokens":12,"total_tokens":24}}'
add_request_termination "openai-completions" '{"id":"cmpl-mock","object":"text_completion","created":1728000002,"model":"gpt-4.1-mini","choices":[{"text":"This is a mocked completion from Kong Gateway.","index":0,"finish_reason":"stop"}],"usage":{"prompt_tokens":8,"completion_tokens":9,"total_tokens":17}}'
add_request_termination "openai-embeddings" '{"object":"list","data":[{"object":"embedding","index":0,"embedding":[0.01,0.02,0.03,0.04]}],"model":"text-embedding-3-small","usage":{"prompt_tokens":4,"total_tokens":4}}'

add_file_log
add_key_auth

echo "Kong mock configuration complete."
