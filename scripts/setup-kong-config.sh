#!/bin/bash

# Set up Kong OpenAI API V1 mock configuration

# Create a service for the OpenAI API
curl -i -X POST http://localhost:8001/services/ \
  --data 'name=openai-api' \
  --data 'url=http://api.openai.com'

# Create a route for the OpenAI API
curl -i -X POST http://localhost:8001/services/openai-api/routes \
  --data 'paths[]=/v1/openai'

# Create a consumer for API keys
curl -i -X POST http://localhost:8001/consumers/ \
  --data 'username=openai-consumer'

# Create an API key for the consumer
curl -i -X POST http://localhost:8001/consumers/openai-consumer/key-auth \
  --data 'key=my-api-key'

# Enable key-auth plugin for the route
curl -i -X POST http://localhost:8001/routes/{route_id}/plugins \
  --data 'name=key-auth'