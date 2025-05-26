#!/bin/bash

# Chrome DevTools MCP Server - Easy Setup Script
# This script automates the entire setup process for non-technical users

set -e

echo "🎉 Welcome to Chrome DevTools MCP Server Easy Setup!"
echo "This script will set everything up automatically."
echo ""

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Function to check if Docker is installed
check_docker() {
    if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to install Docker Desktop
install_docker() {
    local os=$(detect_os)
    echo "📦 Docker not found. Installing Docker Desktop..."
    
    case $os in
        "macos")
            echo "Please download Docker Desktop from: https://www.docker.com/products/docker-desktop/"
            echo "After installation, please run this script again."
            exit 1
            ;;
        "linux")
            echo "Installing Docker via package manager..."
            sudo apt-get update
            sudo apt-get install -y docker.io docker-compose
            sudo systemctl start docker
            sudo usermod -aG docker $USER
            echo "Please log out and log back in, then run this script again."
            exit 1
            ;;
        "windows")
            echo "Please download Docker Desktop from: https://www.docker.com/products/docker-desktop/"
            echo "After installation, please run this script again."
            exit 1
            ;;
    esac
}

# Function to find Claude Desktop config
find_claude_config() {
    local os=$(detect_os)
    case $os in
        "macos")
            echo "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
            ;;
        "linux")
            echo "$HOME/.config/Claude/claude_desktop_config.json"
            ;;
        "windows")
            echo "$APPDATA/Claude/claude_desktop_config.json"
            ;;
    esac
}

# Function to update Claude Desktop config
update_claude_config() {
    local config_file=$(find_claude_config)
    local config_dir=$(dirname "$config_file")
    
    echo "🔧 Configuring Claude Desktop..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"
    
    # Create or update config file
    if [[ -f "$config_file" ]]; then
        echo "Backing up existing config..."
        cp "$config_file" "$config_file.backup"
    fi
    
    # Create new config with chrome-devtools server
    cat > "$config_file" << 'EOF'
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "docker",
      "args": [
        "exec",
        "chrome-devtools-mcp-server",
        "node",
        "/app/build/index.js"
      ]
    }
  }
}
EOF
    
    echo "✅ Claude Desktop configured!"
}

# Main setup process
main() {
    echo "🔍 Checking system requirements..."
    
    # Check Docker
    if ! check_docker; then
        install_docker
    fi
    
    echo "✅ Docker is available!"
    
    # Start the server
    echo "🚀 Starting Chrome DevTools MCP Server..."
    ./start-docker.sh start
    
    # Configure Claude Desktop
    update_claude_config
    
    echo ""
    echo "🎉 Setup Complete!"
    echo ""
    echo "Next steps:"
    echo "1. Restart Claude Desktop if it's running"
    echo "2. In Claude, try saying: 'Connect to my Chrome browser'"
    echo "3. Use commands like: 'Navigate to google.com' or 'Take a screenshot'"
    echo ""
    echo "To manage the server:"
    echo "  Start:   ./start-docker.sh start"
    echo "  Stop:    ./start-docker.sh stop"
    echo "  Status:  ./start-docker.sh status"
    echo ""
}

# Run main function
main 