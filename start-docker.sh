#!/bin/bash

# Chrome DevTools MCP Server - Docker Management Script

set -e

case "$1" in
    start)
        echo "🚀 Starting Chrome DevTools MCP Server..."
        docker-compose up -d
        echo "✅ Server started! Chrome DevTools available at http://localhost:9222"
        echo "📋 Use 'docker-compose logs -f' to view logs"
        ;;
    stop)
        echo "🛑 Stopping Chrome DevTools MCP Server..."
        docker-compose down
        echo "✅ Server stopped!"
        ;;
    restart)
        echo "🔄 Restarting Chrome DevTools MCP Server..."
        docker-compose down
        docker-compose up -d
        echo "✅ Server restarted!"
        ;;
    logs)
        echo "📋 Showing logs (Ctrl+C to exit)..."
        docker-compose logs -f
        ;;
    status)
        echo "📊 Server status:"
        docker-compose ps
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
        docker-compose build
        echo "✅ Build complete!"
        ;;
    clean)
        echo "🧹 Cleaning up Docker resources..."
        docker-compose down -v
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