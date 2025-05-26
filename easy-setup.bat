@echo off
setlocal enabledelayedexpansion

REM Chrome DevTools MCP Server - Easy Setup Script for Windows
REM This script automates the entire setup process for non-technical users

echo 🎉 Welcome to Chrome DevTools MCP Server Easy Setup!
echo This script will set everything up automatically.
echo.

REM Function to check if Docker is installed
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo 📦 Docker not found. Please install Docker Desktop...
    echo.
    echo Please download Docker Desktop from: https://www.docker.com/products/docker-desktop/
    echo After installation, please run this script again.
    echo.
    pause
    exit /b 1
)

where docker-compose >nul 2>nul
if %errorlevel% neq 0 (
    echo 📦 Docker Compose not found. Please install Docker Desktop...
    echo.
    echo Please download Docker Desktop from: https://www.docker.com/products/docker-desktop/
    echo After installation, please run this script again.
    echo.
    pause
    exit /b 1
)

echo ✅ Docker is available!

REM Start the server
echo 🚀 Starting Chrome DevTools MCP Server...
call start-docker.sh start

REM Configure Claude Desktop
echo 🔧 Configuring Claude Desktop...

set "config_dir=%APPDATA%\Claude"
set "config_file=%config_dir%\claude_desktop_config.json"

REM Create config directory if it doesn't exist
if not exist "%config_dir%" mkdir "%config_dir%"

REM Backup existing config if it exists
if exist "%config_file%" (
    echo Backing up existing config...
    copy "%config_file%" "%config_file%.backup" >nul
)

REM Create new config with chrome-devtools server
(
echo {
echo   "mcpServers": {
echo     "chrome-devtools": {
echo       "command": "docker",
echo       "args": [
echo         "exec",
echo         "chrome-devtools-mcp-server",
echo         "node",
echo         "/app/build/index.js"
echo       ]
echo     }
echo   }
echo }
) > "%config_file%"

echo ✅ Claude Desktop configured!

echo.
echo 🎉 Setup Complete!
echo.
echo Next steps:
echo 1. Restart Claude Desktop if it's running
echo 2. In Claude, try saying: 'Connect to my Chrome browser'
echo 3. Use commands like: 'Navigate to google.com' or 'Take a screenshot'
echo.
echo To manage the server:
echo   Start:   start-docker.sh start
echo   Stop:    start-docker.sh stop
echo   Status:  start-docker.sh status
echo.
pause 