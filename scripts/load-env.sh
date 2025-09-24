#!/usr/bin/env bash
# Load project-local environment without touching global shell config.
# Precedence: load .env first (shared defaults), then override with .env.local (machine-specific secrets).
# Does not print secrets.
# Usage: source scripts/load-env.sh

# Export variables loaded from files
set -o allexport
if [ -f ./.env ]; then
  . ./.env
fi
if [ -f ./.env.local ]; then
  . ./.env.local
fi
set +o allexport

