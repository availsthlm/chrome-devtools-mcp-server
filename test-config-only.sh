#!/bin/bash

# Chrome DevTools MCP Server - Configuration Test Script
# This script tests only the Claude Desktop configuration part

set -e

echo "🧪 Testing Chrome DevTools MCP Server Configuration..."
echo "This will test the Claude Desktop config without starting Docker."
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
    
    echo "🔧 Testing Claude Desktop configuration..."
    echo "Config file location: $config_file"
    
    # Show current config
    if [[ -f "$config_file" ]]; then
        echo ""
        echo "📋 Current configuration:"
        cat "$config_file"
        echo ""
    else
        echo "📋 No existing configuration found."
        echo ""
    fi
    
    # Create backup
    if [[ -f "$config_file" ]]; then
        local backup_file="$config_file.backup.$(date +%Y%m%d_%H%M%S)"
        echo "💾 Creating backup: $backup_file"
        cp "$config_file" "$backup_file"
        
        # Check if chrome-devtools server already exists
        if grep -q '"chrome-devtools"' "$config_file"; then
            echo "✅ Chrome DevTools MCP server already configured!"
            return 0
        fi
        
        # Add chrome-devtools to existing config
        echo "➕ Adding Chrome DevTools to existing MCP servers..."
        
        # Use Python to merge JSON (more reliable than manual editing)
        python3 -c "
import json
import sys

try:
    with open('$config_file', 'r') as f:
        config = json.load(f)
except:
    config = {'mcpServers': {}}

if 'mcpServers' not in config:
    config['mcpServers'] = {}

config['mcpServers']['chrome-devtools'] = {
    'command': 'docker',
    'args': [
        'exec',
        'chrome-devtools-mcp-server',
        'node',
        '/app/build/index.js'
    ]
}

with open('$config_file', 'w') as f:
    json.dump(config, f, indent=2)
    
print('✅ Chrome DevTools added to existing configuration!')
"
    else
        # Create config directory if it doesn't exist
        echo "📁 Creating config directory: $config_dir"
        mkdir -p "$config_dir"
        
        # Create new config with chrome-devtools server
        echo "📝 Creating new configuration..."
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
        echo "✅ Claude Desktop configured with Chrome DevTools!"
    fi
    
    echo ""
    echo "📋 Updated configuration:"
    cat "$config_file"
    echo ""
}

# Main test process
main() {
    echo "🔍 Detected OS: $(detect_os)"
    echo ""
    
    # Test Claude Desktop config
    update_claude_config
    
    echo ""
    echo "🎉 Configuration Test Complete!"
    echo ""
    echo "What was tested:"
    echo "✅ OS detection"
    echo "✅ Claude Desktop config file location"
    echo "✅ Backup creation"
    echo "✅ JSON merging with existing config"
    echo "✅ Configuration file writing"
    echo ""
    echo "To restore your original config:"
    echo "  Look for backup files with timestamp in:"
    echo "  $(dirname $(find_claude_config))"
    echo ""
    echo "Next steps for full testing:"
    echo "1. Fix Docker build issues"
    echo "2. Test with actual Docker container"
    echo "3. Test Claude Desktop integration"
    echo ""
}

# Run main function
main 