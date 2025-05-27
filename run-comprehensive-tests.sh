#!/bin/bash

# Chrome DevTools MCP Server - Comprehensive Test Suite
# This script tests all components of the setup

set -e

echo "🧪 Chrome DevTools MCP Server - Comprehensive Test Suite"
echo "========================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "${BLUE}🔍 Testing: $test_name${NC}"
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL: $test_name${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Function to run a test with output
run_test_with_output() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "${BLUE}🔍 Testing: $test_name${NC}"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ PASS: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL: $test_name${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo "1. 🏗️  Build and Environment Tests"
echo "=================================="

run_test "Node.js is available" "command -v node"
run_test "npm is available" "command -v npm"
run_test "Docker is available" "command -v docker"
run_test "Docker Compose is available" "docker compose version || command -v docker-compose"
run_test "TypeScript project builds" "npm run build"
run_test "Package.json is valid" "npm list --depth=0"

echo ""
echo "2. 🐳 Docker Tests"
echo "=================="

run_test "Docker image builds successfully" "docker build -t chrome-devtools-mcp-test-suite ."
run_test "Docker Compose configuration is valid" "docker compose config"

echo ""
echo "3. 🚀 MCP Server Tests"
echo "====================="

# Test MCP server directly
echo -e "${BLUE}🔍 Testing: MCP server can list tools${NC}"
if echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list", "params": {}}' | node build/index.js | grep -q '"tools"'; then
    echo -e "${GREEN}✅ PASS: MCP server can list tools${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}❌ FAIL: MCP server can list tools${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""
echo "4. 🌐 Docker Integration Tests"
echo "=============================="

# Start Docker Compose
echo -e "${BLUE}🔍 Starting Docker Compose for integration tests...${NC}"
./start-docker.sh stop > /dev/null 2>&1 || true
./start-docker.sh start

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"
sleep 15

run_test "Docker container is running" "docker ps | grep -q chrome-devtools-mcp-server"
run_test "Chrome DevTools port is accessible" "curl -s http://localhost:9222/json/version"

# Create a tab for testing
echo -e "${BLUE}🔍 Creating Chrome tab for testing...${NC}"
curl -s -X PUT "http://localhost:9222/json/new?about:blank" > /dev/null

run_test "Chrome has inspectable targets" "curl -s http://localhost:9222/json | grep -q 'id'"

echo ""
echo "5. 📋 Configuration Tests"
echo "========================"

run_test "Easy setup script syntax is valid" "bash -n easy-setup.sh"
run_test "Start Docker script syntax is valid" "bash -n start-docker.sh"
run_test "Test config script syntax is valid" "bash -n test-config-only.sh"

echo ""
echo "6. 🧹 Cleanup"
echo "============="

echo -e "${BLUE}🔍 Cleaning up test resources...${NC}"
./start-docker.sh stop > /dev/null 2>&1
docker rmi chrome-devtools-mcp-test-suite > /dev/null 2>&1 || true

echo ""
echo "📊 Test Results Summary"
echo "======================="
echo -e "Total Tests: ${TESTS_TOTAL}"
echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"
echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All tests passed! Your Chrome DevTools MCP Server setup is working perfectly!${NC}"
    echo ""
    echo "✅ Ready for production use!"
    echo "✅ Docker setup is functional"
    echo "✅ MCP server is operational"
    echo "✅ Scripts are working correctly"
    echo ""
    echo "Next steps:"
    echo "1. Run './easy-setup.sh' to configure Claude Desktop"
    echo "2. Restart Claude Desktop"
    echo "3. Try commands like 'Connect to my Chrome browser'"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Some tests failed. Please check the issues above.${NC}"
    exit 1
fi 