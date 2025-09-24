#!/usr/bin/env bash
# Load project-local environment without touching global shell config.
# Prefer .env.local; fall back to .env if present. Does not print secrets.
# Usage: source scripts/load-env.sh

# Export variables loaded from files
set -o allexport
if [ -f ./.env.local ]; then
  . ./.env.local
fi
if [ -f ./.env ]; then
  . ./.env
fi
set +o allexport

