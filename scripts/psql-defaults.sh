#!/usr/bin/env bash
# Project-local defaults for psql.
# Usage: source this file in your shell to apply safe defaults:
#   source scripts/psql-defaults.sh
# Sets a conservative statement timeout to avoid hangs during ad-hoc queries.
# For Supabase local (PgBouncer on 54322), prefer scripts/psql-local which issues
# a SET statement_timeout per-session. Avoid using PGOPTIONS with PgBouncer.

# Default timeout in seconds for psql-local wrapper
export PSQL_DEFAULT_TIMEOUT_SECONDS="${PSQL_DEFAULT_TIMEOUT_SECONDS:-10}"

# If connecting directly to Postgres (not via PgBouncer), you may optionally enable:
# export PGOPTIONS="-c statement_timeout=${PSQL_DEFAULT_TIMEOUT_SECONDS}s"
