# Developer Documentation

This document contains comprehensive information for developers, testers, and contributors working on the Chrome DevTools MCP Server.

## Testing

### Quick Test

Run the comprehensive test suite:

```bash
./run-comprehensive-tests.sh
```

This will test all components and give you a complete status report.

### Manual Testing

#### 1. Build Tests

```bash
# Test TypeScript compilation
npm run build

# Test MCP server directly
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list", "params": {}}' | node build/index.js
```

#### 2. Docker Tests

```bash
# Test Docker build
docker build -t chrome-devtools-mcp-test .

# Test Docker Compose
./start-docker.sh start
./start-docker.sh status
./start-docker.sh stop
```

#### 3. Chrome DevTools Integration

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

### Test Results

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

## Distribution Strategy

### Current State vs. Target State

#### Current State (Technical Users Only)

- Requires command line knowledge
- Manual Docker installation
- JSON configuration editing
- Git repository cloning
- Understanding of MCP concepts

#### Target State (Non-Technical Friendly)

- One-click installer
- Automatic dependency management
- GUI-based configuration
- Pre-packaged downloads
- Simple language explanations

### Distribution Methods

#### 1. GitHub Releases with Pre-built Packages

Create downloadable packages for each OS:

```
chrome-devtools-mcp-v1.0-macos.zip
├── easy-setup.sh (executable)
├── start-docker.sh
├── docker-compose.yml
├── README.md
└── Dockerfile
```

**Benefits:**

- No Git knowledge required
- Single download link
- Version-controlled releases
- Automatic updates possible

#### 2. Installer Applications

**Option A: Electron-based Installer**

- Cross-platform desktop app
- GUI wizard interface
- Automatic dependency detection
- System tray integration
- One-time setup, persistent management

**Option B: Native Installers**

- `.dmg` for macOS
- `.msi` for Windows
- `.deb`/`.rpm` for Linux
- Platform-specific optimizations

#### 3. Package Manager Distribution

For slightly technical users:

- Homebrew (macOS): `brew install chrome-devtools-mcp`
- Chocolatey (Windows): `choco install chrome-devtools-mcp`
- Snap (Linux): `snap install chrome-devtools-mcp`

### User Journey Optimization

#### Current Journey (Complex)

1. Find GitHub repository
2. Clone or download
3. Install Docker manually
4. Run terminal commands
5. Edit JSON configuration
6. Restart Claude Desktop
7. Test functionality

#### Optimized Journey (Simple)

1. Download installer from website
2. Double-click to run
3. Follow 3-4 simple prompts
4. Everything works automatically

## Development

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

### Built With

- `@modelcontextprotocol/sdk` for MCP protocol
- `chrome-remote-interface` for Chrome DevTools Protocol
- TypeScript for type safety
- Docker for containerization

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

## Implementation Roadmap

### Phase 1: Immediate Improvements (1-2 weeks)

- [x] Create `easy-setup.sh` script
- [x] Create `easy-setup.bat` for Windows
- [x] Consolidate documentation
- [ ] Test scripts on clean systems
- [ ] Create GitHub release with packages

### Phase 2: Installer Application (2-4 weeks)

- [ ] Build Electron-based installer
- [ ] Add GUI for server management
- [ ] Implement auto-update mechanism
- [ ] Create platform-specific packages

### Phase 3: Web Presence (1-2 weeks)

- [ ] Create landing page website
- [ ] Record demonstration videos
- [ ] Set up community support channels
- [ ] Write comprehensive FAQ

### Phase 4: Advanced Features (4-6 weeks)

- [ ] System tray integration
- [ ] Health monitoring dashboard
- [ ] Usage analytics (privacy-respecting)
- [ ] Plugin system for extensions

## Success Metrics

### User Experience Metrics

- Setup time: Target < 5 minutes
- Success rate: Target > 90% first-time setup
- Support requests: Target < 5% of users need help

### Adoption Metrics

- Downloads per month
- Active users (via opt-in telemetry)
- Community engagement (Discord, GitHub issues)

## Performance Testing

For performance testing, you can:

1. Monitor resource usage: `docker stats`
2. Test multiple concurrent connections
3. Measure response times for different operations
4. Test with various page sizes and complexities

## Security Considerations

- Only run this with Chrome instances you control
- The remote debugging port gives full access to the browser
- Don't expose the debugging port to untrusted networks
- Use temporary user data directories for testing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run the test suite
5. Submit a pull request

All contributions should include appropriate tests and documentation updates.
