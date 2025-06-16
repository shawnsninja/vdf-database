#!/bin/bash
# Generate .mcp.json from template and environment variables

# Load environment variables from .env file
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

# Check if template exists
if [ ! -f .mcp.json.template ]; then
  echo "Error: .mcp.json.template not found!"
  exit 1
fi

# Generate .mcp.json by substituting environment variables
envsubst < .mcp.json.template > .mcp.json

echo "✅ Generated .mcp.json from template with environment variables"
echo "🔒 Remember: .mcp.json is in .gitignore to protect your secrets"