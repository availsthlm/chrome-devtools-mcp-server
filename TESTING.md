# Testing Guide

This document explains how to test the Chrome DevTools MCP Server setup to ensure everything is working correctly.

## Quick Test

Run the comprehensive test suite:

```bash
./run-comprehensive-tests.sh
```

This will test all components and give you a complete status report.

## Manual Testing

### 1. Build Tests

```bash
# Test TypeScript compilation
npm run build

# Test MCP server directly
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list", "params": {}}' | node build/index.js
```

### 2. Docker Tests

```bash
# Test Docker build
docker build -t chrome-devtools-mcp-test .

# Test Docker Compose
./start-docker.sh start
./start-docker.sh status
./start-docker.sh stop
```

### 3. Chrome DevTools Integration

```bash
# Start the server
./start-docker.sh start

# Wait for startup
sleep 15

# Test Chrome DevTools API
curl http://localhost:9222/json/version

# Create a tab
curl -X PUT "http://localhost:9222/json/new?about:blank"

# List tabs
curl http://localhost:9222/json
```

### 4. MCP Server Functionality

With the Docker container running, you can test the MCP server tools:

```bash
# Connect to Chrome (requires a tab to exist)
# Navigate to a URL
# Execute JavaScript
# Take screenshots
# Get page content
```

### 5. Configuration Tests

```bash
# Test Claude Desktop configuration (dry run)
./test-config-only.sh

# Test easy setup script syntax
bash -n easy-setup.sh
```

## Test Results

The comprehensive test suite checks:

- ✅ Node.js and npm availability
- ✅ Docker and Docker Compose functionality
- ✅ TypeScript compilation
- ✅ Package dependencies
- ✅ Docker image building
- ✅ Docker Compose configuration
- ✅ MCP server tool listing
- ✅ Docker container execution
- ✅ Chrome DevTools API accessibility
- ✅ Chrome tab creation and management
- ✅ Script syntax validation

## Troubleshooting

### Common Issues

1. **Chrome fails to start in Docker**

   - Check Docker logs: `docker compose logs`
   - Verify Chrome binary installation
   - Check X11 display setup

2. **MCP server connection fails**

   - Ensure Chrome has at least one tab open
   - Check port 9222 accessibility
   - Verify Docker container is healthy

3. **Docker build fails**
   - Check internet connectivity
   - Verify Docker daemon is running
   - Clear Docker cache: `docker system prune`

### Debug Commands

```bash
# Check Docker container status
docker ps

# View detailed logs
docker compose logs -f

# Execute commands in container
docker exec -it chrome-devtools-mcp-server bash

# Check Chrome process
docker exec chrome-devtools-mcp-server ps aux | grep chrome

# Test Chrome DevTools directly
docker exec chrome-devtools-mcp-server curl localhost:9222/json/version
```

## Performance Testing

For performance testing, you can:

1. Monitor resource usage: `docker stats`
2. Test multiple concurrent connections
3. Measure response times for different operations
4. Test with various page sizes and complexities

## Automated Testing

The test suite can be integrated into CI/CD pipelines:

```bash
# Exit code 0 = all tests passed
# Exit code 1 = some tests failed
./run-comprehensive-tests.sh
echo "Exit code: $?"
```
