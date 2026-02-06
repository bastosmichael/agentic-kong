#!/bin/bash

# Create a Kong configuration setup script

# Step 1: Set up Env Variables
export KONG_DATABASE=off
export KONG_PROXY_LISTEN=0.0.0.0:8000
export KONG_ADMIN_LISTEN=0.0.0.0:8001

# Step 2: Start Kong
kong reload

# Step 3: Check Kong Status
kong health
