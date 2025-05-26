#!/bin/bash

# Wait for Chrome to be ready
echo "Waiting for Chrome to start..."
while ! curl -s http://localhost:9222/json > /dev/null; do
    sleep 1
done
echo "Chrome is ready!"

# Start the MCP server
echo "Starting MCP server..."
cd /app
exec node build/index.js 