# Docker Configuration

This directory contains Docker configuration files for the Chrome DevTools MCP Server with Chrome browser included.

> **Note**: Basic Docker usage is covered in the main README.md. This document covers advanced Docker configuration and troubleshooting.

## Quick Start

See the main README.md for basic setup. For advanced usage:

```bash
# Build and start
docker-compose up -d

# Monitor
docker-compose ps
docker-compose logs -f

# Stop
docker-compose down
```

## What's Included

- **Chrome Browser**: Headless Chrome with remote debugging enabled
- **MCP Server**: The Chrome DevTools MCP server
- **Xvfb**: Virtual display for Chrome
- **Supervisor**: Process manager to keep everything running

## Ports

- **9222**: Chrome DevTools Protocol (main interface)
- **5900**: VNC (optional, for visual debugging)

## Configuration Files

- `Dockerfile`: Main container definition
- `docker-compose.yml`: Service orchestration
- `supervisord.conf`: Process management
- `start-chrome.sh`: Chrome startup script
- `start-mcp.sh`: MCP server startup script

## Usage with Claude Desktop

See the main README.md for Claude Desktop configuration. This Docker setup uses the same configuration as documented there.

## Debugging

### View Chrome DevTools

Navigate to `http://localhost:9222` in your browser to see available Chrome tabs and debugging interfaces.

### VNC Access (Optional)

If you need to see the Chrome browser visually:

```bash
# Install VNC viewer and connect to localhost:5900
vncviewer localhost:5900
```

### Container Logs

```bash
# All logs
docker-compose logs

# Specific service logs
docker logs chrome-devtools-mcp-server

# Follow logs in real-time
docker-compose logs -f chrome-devtools-mcp
```

### Exec into Container

```bash
docker exec -it chrome-devtools-mcp-server bash
```

## Troubleshooting

1. **Container won't start**: Check Docker logs for errors
2. **Chrome not accessible**: Ensure port 9222 is not blocked
3. **MCP server not responding**: Check if Chrome started successfully first
4. **Permission issues**: The container runs as root to avoid Chrome sandbox issues

## Health Checks

The container includes health checks that verify Chrome is responding on port 9222. You can check the health status:

```bash
docker inspect chrome-devtools-mcp-server | grep -A 10 Health
```

## Persistent Data

Chrome user data is stored in a Docker volume (`chrome-data`) to persist between container restarts.

## Security Notes

- The container runs with `--no-sandbox` for Chrome compatibility
- Remote debugging is exposed on all interfaces (0.0.0.0)
- Only expose port 9222 to trusted networks
- Consider using a reverse proxy for production deployments
