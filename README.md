# Chrome DevTools MCP Server

A Model Context Protocol (MCP) server that provides tools for interacting with Chrome DevTools Protocol. This allows you to programmatically control Chrome browser instances through Claude Desktop, navigate web pages, execute JavaScript, take screenshots, and more.

## 🚀 Quick Start

### For Non-Technical Users (Recommended)

**What this does**: Control Chrome browser through Claude Desktop with simple voice commands like "navigate to google.com" or "take a screenshot"!

1. **Download**: Click the green "Code" button → "Download ZIP" → Extract to Desktop
2. **One-Click Setup**:
   - **Mac**: Double-click `easy-setup.sh`
   - **Windows**: Double-click `easy-setup.bat`
3. **Restart Claude Desktop**
4. **Start using**: Say "Connect to my Chrome browser" in Claude!

[Need help? See troubleshooting below](#troubleshooting)

### For Technical Users

```bash
# Clone and start with Docker (recommended)
git clone <repository-url>
cd chrome-devtools-mcp-server
docker-compose up -d

# Or manual installation
npm install && npm run build && npm start
```

## Features

- 🌐 **Browser Control**: Navigate URLs, click elements, fill forms
- 📸 **Screenshots**: Capture full pages or specific elements
- 🔧 **JavaScript Execution**: Run custom scripts in browser context
- 📱 **Device Emulation**: Test mobile/tablet views
- 🔍 **Network Monitoring**: Track requests and responses
- 📝 **Console Access**: View browser console logs
- 🔗 **Multiple Connections**: Manage multiple Chrome instances

## Installation Options

### Option 1: Docker (Recommended)

The easiest and most reliable method - includes Chrome and all dependencies:

```bash
# Start everything
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

### Option 2: Manual Installation

1. **Start Chrome with debugging enabled**:

   ```bash
   # macOS/Linux
   google-chrome --remote-debugging-port=9222 --no-first-run --no-default-browser-check --user-data-dir=/tmp/chrome-debug

   # Windows
   chrome.exe --remote-debugging-port=9222 --no-first-run --no-default-browser-check --user-data-dir=c:\temp\chrome-debug
   ```

2. **Install and build**:
   ```bash
   npm install
   npm run build
   npm start
   ```

## Configuration with Claude Desktop

### Docker Setup

```json
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
```

### Manual Setup

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "node",
      "args": ["/path/to/chrome-devtools-mcp-server/build/index.js"]
    }
  }
}
```

## Available Tools

| Tool                   | Description                | Parameters                     |
| ---------------------- | -------------------------- | ------------------------------ |
| `connect_chrome`       | Connect to Chrome DevTools | `host`, `port`, `connectionId` |
| `list_tabs`            | List all browser tabs      | -                              |
| `navigate_to_url`      | Navigate to a URL          | `url`                          |
| `execute_javascript`   | Run JavaScript code        | `code`                         |
| `get_page_content`     | Get HTML content           | -                              |
| `take_screenshot`      | Capture screenshot         | `format`, `quality`            |
| `set_device_emulation` | Emulate mobile devices     | `width`, `height`, `mobile`    |
| `get_network_requests` | Monitor network traffic    | -                              |
| `get_console_logs`     | Access console logs        | -                              |
| `disconnect_chrome`    | Close connection           | `connectionId`                 |

## Example Usage

Just talk to Claude naturally:

- **"Connect to my Chrome browser"**
- **"Navigate to amazon.com"**
- **"Take a screenshot of this page"**
- **"Make the browser look like an iPhone"**
- **"Execute JavaScript to click the login button"**
- **"Get the page title and all links"**

## Troubleshooting

### "Docker not found" or "Connection failed"

1. **Install Docker Desktop** (the setup script will guide you)
2. **Restart your computer** after Docker installation
3. **Run the setup again**: `./easy-setup.sh` or `easy-setup.bat`

### "Claude can't connect to Chrome"

1. **Restart Claude Desktop completely**
2. **Check Docker is running**: `docker-compose ps`
3. **Try connecting again**: Say "Connect to Chrome" in Claude

### Chrome debugging issues

1. **Only one process can use port 9222** - close other Chrome debugging sessions
2. **Check if Chrome is running**: Navigate to `http://localhost:9222`
3. **Restart Docker container**: `docker-compose restart`

### Still having problems?

```bash
# Check status
./start-docker.sh status

# View logs
docker-compose logs -f

# Complete restart
docker-compose down && docker-compose up -d
```

## Testing

Run the comprehensive test suite:

```bash
./run-comprehensive-tests.sh
```

This tests all components and provides a complete status report.

## Security Notes

⚠️ **Important**:

- Only use with Chrome instances you control
- Don't expose port 9222 to untrusted networks
- Use temporary user data directories for testing
- The debugging port gives full browser access

## Development

Built with TypeScript and:

- `@modelcontextprotocol/sdk` for MCP protocol
- `chrome-remote-interface` for Chrome DevTools Protocol

### Project Structure

```
├── src/index.ts           # Main server implementation
├── build/                 # Compiled JavaScript
├── docker/               # Docker configuration
├── easy-setup.sh         # One-click setup script
├── docker-compose.yml    # Service orchestration
└── package.json          # Dependencies and scripts
```

### Adding New Tools

1. Add tool definition in `setupToolHandlers()`
2. Implement the handler method
3. Add case in CallToolRequestSchema handler

## What Gets Installed

When you run the easy setup:

- **Docker Desktop**: Safely runs Chrome in a container
- **Chrome DevTools Server**: Connects Claude to Chrome
- **Claude Configuration**: Automatically configures Claude Desktop

## Uninstalling

```bash
# Remove Docker containers and data
./start-docker.sh clean

# Optional: Uninstall Docker Desktop
# Delete this folder
```

## License

MIT License - see LICENSE file for details

---

**🎯 Goal**: Make browser automation accessible to everyone through natural language with Claude!
