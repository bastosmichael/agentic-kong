#!/bin/bash

# Kong Admin API setup commands for OpenAI API V1 mock service

# Create a mock service for OpenAI API V1
curl -i -X POST http://localhost:8001/services/ --data 'name=openai-mock' --data 'url=http://mock-service-url.com'

# Create a route for the mock service
curl -i -X POST http://localhost:8001/services/openai-mock/routes --data 'paths[]=/v1/openai'

# Add any additional setup commands here
echo "Kong mock service for OpenAI API V1 has been set up successfully!"