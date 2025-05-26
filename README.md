# Chrome DevTools MCP Server

A Model Context Protocol (MCP) server that provides tools for interacting with Chrome DevTools Protocol. This allows you to programmatically control Chrome browser instances, navigate web pages, execute JavaScript, take screenshots, and more.

## Features

- Connect to Chrome DevTools instances
- Navigate to URLs and control page interactions
- Execute JavaScript code in browser context
- Take screenshots of web pages
- Get page HTML content
- Device emulation for mobile testing
- Network request monitoring
- Console log access
- Multiple connection support

## Prerequisites

1. **Chrome Browser**: You need Chrome or Chromium installed
2. **Chrome with Remote Debugging**: Start Chrome with remote debugging enabled:

```bash
# On macOS/Linux
google-chrome --remote-debugging-port=9222 --no-first-run --no-default-browser-check --user-data-dir=/tmp/chrome-debug

# On Windows
chrome.exe --remote-debugging-port=9222 --no-first-run --no-default-browser-check --user-data-dir=c:\temp\chrome-debug
```

## Installation

### Option 1: Docker (Recommended)

The easiest way to run this MCP server is using Docker, which includes Chrome and all dependencies:

```bash
# Clone the repository
git clone <repository-url>
cd chrome-devtools-mcp-server

# Start with Docker Compose
docker-compose up -d

# Check if it's running
docker-compose ps

# View logs
docker-compose logs -f
```

The server will be available at `http://localhost:9222` for Chrome DevTools Protocol.

### Option 2: Manual Installation

1. Clone or create the project:

```bash
mkdir chrome-devtools-mcp-server
cd chrome-devtools-mcp-server
```

2. Create the files (index.ts, package.json, tsconfig.json) in a `src` directory

3. Install dependencies:

```bash
npm install
```

4. Build the project:

```bash
npm run build
```

## Usage

### Starting the MCP Server

The server runs on stdio transport:

```bash
npm start
```

Or for development with auto-rebuild:

```bash
npm run dev
```

### Available Tools

1. **connect_chrome**: Connect to a Chrome DevTools instance

   - `host`: Chrome host (default: localhost)
   - `port`: Chrome port (default: 9222)
   - `connectionId`: Unique connection identifier

2. **list_tabs**: List all available browser tabs/targets

3. **navigate_to_url**: Navigate to a specific URL

   - `url`: Target URL to navigate to

4. **execute_javascript**: Execute JavaScript in the browser context

   - `code`: JavaScript code to execute

5. **get_page_content**: Get the HTML content of the current page

6. **take_screenshot**: Capture a screenshot of the current page

   - `format`: png or jpeg
   - `quality`: JPEG quality (0-100)

7. **set_device_emulation**: Emulate mobile devices or set custom viewport

   - `width`: Viewport width
   - `height`: Viewport height
   - `deviceScaleFactor`: Device scale factor
   - `mobile`: Whether to emulate mobile

8. **disconnect_chrome**: Disconnect from Chrome DevTools
   - `connectionId`: Connection to close

### Configuration with Claude Desktop

#### For Docker Setup (Recommended)

Add this to your Claude Desktop configuration:

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

#### For Manual Installation

Add this to your Claude Desktop configuration:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "node",
      "args": ["/path/to/your/chrome-devtools-mcp-server/build/index.js"]
    }
  }
}
```

## Example Usage

### Docker Setup

Once you have the Docker container running:

1. **The Chrome browser is automatically started** - no manual setup needed!

2. **In Claude, connect to Chrome**:

```
Can you connect to my Chrome browser using the chrome devtools?
```

3. **Navigate to a website**:

```
Please navigate to https://example.com
```

4. **Take a screenshot**:

```
Can you take a screenshot of the current page?
```

5. **Execute JavaScript**:

```
Can you execute some JavaScript to get the page title?
```

### Manual Setup

If you're not using Docker:

1. **Start Chrome with debugging**:

```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 --no-first-run --no-default-browser-check --user-data-dir=/tmp/chrome-debug
```

2. **Follow the same steps as above** for connecting to Chrome, navigating, taking screenshots, etc.

## Development

The server is built with TypeScript and uses:

- `@modelcontextprotocol/sdk` for MCP protocol implementation
- `chrome-remote-interface` for Chrome DevTools Protocol communication

### Project Structure

```
├── src/
│   └── index.ts          # Main server implementation
├── build/                # Compiled JavaScript output
├── package.json          # Dependencies and scripts
├── tsconfig.json         # TypeScript configuration
└── README.md            # This file
```

### Adding New Tools

To add new Chrome DevTools functionality:

1. Add the tool definition in `setupToolHandlers()`
2. Implement the handler method
3. Add the case in the CallToolRequestSchema handler

## Troubleshooting

1. **Connection failed**: Ensure Chrome is running with `--remote-debugging-port=9222`
2. **Permission denied**: Make sure the user data directory is writable
3. **Port already in use**: Check if another process is using port 9222

## Security Notes

- Only run this with Chrome instances you control
- The remote debugging port gives full access to the browser
- Don't expose the debugging port to untrusted networks
- Use temporary user data directories for testing

## License

MIT License - see LICENSE file for details
