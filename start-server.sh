#!/bin/bash
#
# 1Password + Orion Test Suite - Local Server
#
# This script starts a simple HTTP server to serve the test pages.
# The server runs on http://localhost:8080
#
# Usage: ./start-server.sh
#

set -e

PORT=8080
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_PAGES_DIR="$SCRIPT_DIR/test-pages"
SERVER_SCRIPT="$SCRIPT_DIR/scripts/serve.swift"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}    ${GREEN}1Password + Orion Browser Test Suite${NC}                  ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if port is already in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
	echo -e "${YELLOW}⚠️  Port $PORT is already in use.${NC}"
	echo ""
	echo "Options:"
	echo "  1. The server may already be running - try opening the URL below"
	echo "  2. Stop the existing process: lsof -ti:$PORT | xargs kill"
	echo ""
	echo -e "Test suite: ${GREEN}http://localhost:$PORT/${NC}"
	echo ""
	exit 1
fi

# Check if Swift is available
if ! command -v swift &>/dev/null; then
	echo -e "${RED}❌ Swift is not installed or not in PATH${NC}"
	echo ""
	echo "Swift is required to run the built-in server."
	echo "On macOS, install Xcode Command Line Tools:"
	echo "  xcode-select --install"
	echo ""
	exit 1
fi

# Check if server script exists
if [ ! -f "$SERVER_SCRIPT" ]; then
	echo -e "${RED}❌ Server script not found: $SERVER_SCRIPT${NC}"
	exit 1
fi

# Check if test pages directory exists
if [ ! -d "$TEST_PAGES_DIR" ]; then
	echo -e "${RED}❌ Test pages directory not found: $TEST_PAGES_DIR${NC}"
	exit 1
fi

echo -e "📁 Serving files from: ${BLUE}$TEST_PAGES_DIR${NC}"
echo -e "🌐 Server URL: ${GREEN}http://localhost:$PORT/${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
echo ""
echo "────────────────────────────────────────────────────────────"
echo ""

# Change to test-pages directory and run server
cd "$TEST_PAGES_DIR"
swift "$SERVER_SCRIPT" "$PORT" "."
