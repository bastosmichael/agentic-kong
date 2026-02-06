#!/bin/bash

# Create a service for the OpenAI API
curl -i -X POST http://localhost:8001/services/ \ 
  --data 'name=openai-api' \ 
  --data 'url=http://mock.openai.api'

# Create a route for the OpenAI API
curl -i -X POST http://localhost:8001/routes/ \ 
  --data 'paths[]=/openai' \ 
  --data 'service.id=$(curl -s http://localhost:8001/services/openai-api | jq -r '.id)'

# Add a plugin for rate limiting
curl -i -X POST http://localhost:8001/services/openai-api/plugins/ \ 
  --data 'name=rate-limiting' \ 
  --data 'config.second=5' \ 
  --data 'config.hour=5000'

echo "Kong OpenAI API V1 mock configured successfully!"