#!/usr/bin/env bash
# Project-local defaults for psql.
# Usage: source this file in your shell to apply safe defaults:
#   source scripts/psql-defaults.sh
# This sets a conservative statement timeout to avoid hangs during ad-hoc queries.
# Adjust as needed for heavier analytics.
export PGOPTIONS="-c statement_timeout=10s"
