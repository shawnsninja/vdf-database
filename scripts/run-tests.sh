#!/bin/bash

# Run Tests Script
# Executes test queries against the database to verify migrations

set -e  # Exit on error

echo "🧪 Running VDF Database Tests..."
echo "================================"

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo "❌ Error: DATABASE_URL not set"
    echo "Please set DATABASE_URL or source .env file"
    exit 1
fi

# Function to run a test query
run_test() {
    local test_name="$1"
    local query="$2"
    
    echo -n "Testing $test_name... "
    
    if psql "$DATABASE_URL" -t -c "$query" > /dev/null 2>&1; then
        echo "✅ PASSED"
    else
        echo "❌ FAILED"
        psql "$DATABASE_URL" -c "$query"
    fi
}

# Test 1: Database connection
run_test "database connection" "SELECT 1"

# Test 2: Extensions
run_test "UUID extension" "SELECT extname FROM pg_extension WHERE extname = 'uuid-ossp'"

# Test 3: Core tables
run_test "profiles table" "SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles'"
run_test "media table" "SELECT 1 FROM information_schema.tables WHERE table_name = 'media'"
run_test "translations table" "SELECT 1 FROM information_schema.tables WHERE table_name = 'translations'"

# Test 4: RLS enabled
run_test "RLS on profiles" "SELECT 1 FROM pg_tables WHERE tablename = 'profiles' AND rowsecurity = true"

# Test 5: Functions
run_test "has_role function" "SELECT 1 FROM information_schema.routines WHERE routine_name = 'has_role'"

# Test 6: Seed data
echo ""
echo "📊 Checking seed data counts:"
psql "$DATABASE_URL" -c "
    SELECT 'user_roles_master' as table_name, COUNT(*) as count FROM public.user_roles_master
    UNION ALL
    SELECT 'languages_master', COUNT(*) FROM public.languages_master
" 2>/dev/null || echo "Tables not yet created"

echo ""
echo "================================"
echo "🏁 Test run complete!"

# Run full test script if it exists
if [ -f "scripts/test-migration.sql" ]; then
    echo ""
    echo "Running comprehensive test suite..."
    psql "$DATABASE_URL" -f scripts/test-migration.sql
fi