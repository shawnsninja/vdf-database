#!/bin/bash
# Generate MCP config and start Claude Code

# Change to the script's directory
cd "$(dirname "$0")"

# Generate the MCP configuration from template
./generate-mcp-config.sh

# Start Claude Code
claude