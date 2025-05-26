#!/bin/bash

# Chrome DevTools MCP Server - Docker Management Script

set -e

# Function to get the correct docker compose command
get_docker_compose_cmd() {
    if command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    elif docker compose version &> /dev/null 2>&1; then
        echo "docker compose"
    else
        echo "docker-compose"  # fallback
    fi
}

DOCKER_COMPOSE=$(get_docker_compose_cmd)

case "$1" in
    start)
        echo "🚀 Starting Chrome DevTools MCP Server..."
        $DOCKER_COMPOSE up -d
        echo "✅ Server started! Chrome DevTools available at http://localhost:9222"
        echo "📋 Use '$DOCKER_COMPOSE logs -f' to view logs"
        ;;
    stop)
        echo "🛑 Stopping Chrome DevTools MCP Server..."
        $DOCKER_COMPOSE down
        echo "✅ Server stopped!"
        ;;
    restart)
        echo "🔄 Restarting Chrome DevTools MCP Server..."
        $DOCKER_COMPOSE down
        $DOCKER_COMPOSE up -d
        echo "✅ Server restarted!"
        ;;
    logs)
        echo "📋 Showing logs (Ctrl+C to exit)..."
        $DOCKER_COMPOSE logs -f
        ;;
    status)
        echo "📊 Server status:"
        $DOCKER_COMPOSE ps
        echo ""
        echo "🔍 Health check:"
        if curl -s http://localhost:9222/json > /dev/null; then
            echo "✅ Chrome DevTools is responding"
        else
            echo "❌ Chrome DevTools is not responding"
        fi
        ;;
    build)
        echo "🔨 Building Docker image..."
        $DOCKER_COMPOSE build
        echo "✅ Build complete!"
        ;;
    clean)
        echo "🧹 Cleaning up Docker resources..."
        $DOCKER_COMPOSE down -v
        docker system prune -f
        echo "✅ Cleanup complete!"
        ;;
    *)
        echo "Chrome DevTools MCP Server - Docker Management"
        echo ""
        echo "Usage: $0 {start|stop|restart|logs|status|build|clean}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the server in background"
        echo "  stop    - Stop the server"
        echo "  restart - Restart the server"
        echo "  logs    - Show server logs"
        echo "  status  - Show server status"
        echo "  build   - Build Docker image"
        echo "  clean   - Clean up Docker resources"
        echo ""
        exit 1
        ;;
esac 