#!/bin/bash
# =====================================================================================
# VDF Database Migration Runner
# Description: Applies database migrations in order
# Usage: ./run-migrations.sh [module_number]
# =====================================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo -e "${RED}Error: DATABASE_URL environment variable is not set${NC}"
    echo "Please set it to your Supabase database connection string"
    exit 1
fi

# Get module number from argument (default to all)
MODULE=$1

# Function to run a single migration file
run_migration() {
    local file=$1
    local filename=$(basename "$file")
    
    echo -e "${YELLOW}Running migration: $filename${NC}"
    
    if psql "$DATABASE_URL" -f "$file" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $filename completed${NC}"
    else
        echo -e "${RED}✗ $filename failed${NC}"
        echo "Error output:"
        psql "$DATABASE_URL" -f "$file"
        exit 1
    fi
}

# Function to run migrations for a module
run_module() {
    local module_dir=$1
    local module_name=$(basename "$module_dir")
    
    echo -e "\n${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Running migrations for: $module_name${NC}"
    echo -e "${YELLOW}========================================${NC}\n"
    
    # Check if directory exists
    if [ ! -d "$module_dir" ]; then
        echo -e "${RED}Module directory not found: $module_dir${NC}"
        return 1
    fi
    
    # Get all SQL files except test files, sorted by name
    local files=($(find "$module_dir" -name "*.sql" -not -name "test_*.sql" | sort))
    
    if [ ${#files[@]} -eq 0 ]; then
        echo -e "${YELLOW}No migration files found in $module_dir${NC}"
        return 0
    fi
    
    # Run each migration
    for file in "${files[@]}"; do
        run_migration "$file"
    done
    
    echo -e "\n${GREEN}Module $module_name completed successfully!${NC}"
}

# Main execution
echo -e "${GREEN}VDF Database Migration Runner${NC}"
echo -e "${GREEN}=============================${NC}\n"

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MIGRATIONS_DIR="$SCRIPT_DIR/../migrations"

if [ -n "$MODULE" ]; then
    # Run specific module
    MODULE_DIR="$MIGRATIONS_DIR/00$MODULE-"*
    if [ -d $MODULE_DIR ]; then
        run_module $MODULE_DIR
    else
        echo -e "${RED}Module $MODULE not found${NC}"
        exit 1
    fi
else
    # Run all modules in order
    for module_dir in "$MIGRATIONS_DIR"/*/; do
        if [ -d "$module_dir" ]; then
            run_module "$module_dir"
        fi
    done
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}All migrations completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"

# Offer to run tests
echo -e "\n${YELLOW}Would you like to run the test suite? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    if [ -n "$MODULE" ]; then
        TEST_FILE="$MIGRATIONS_DIR/00$MODULE-"*/test_module_*.sql
        if [ -f $TEST_FILE ]; then
            echo -e "\n${YELLOW}Running tests for Module $MODULE...${NC}"
            psql "$DATABASE_URL" -f $TEST_FILE
        else
            echo -e "${YELLOW}No test file found for Module $MODULE${NC}"
        fi
    else
        echo -e "\n${YELLOW}Running all module tests...${NC}"
        for test_file in "$MIGRATIONS_DIR"/*/test_*.sql; do
            if [ -f "$test_file" ]; then
                echo -e "\n${YELLOW}Running: $(basename "$test_file")${NC}"
                psql "$DATABASE_URL" -f "$test_file"
            fi
        done
    fi
fi