#!/bin/bash

# Supabase Project Setup Script
# This script helps set up the Supabase project for VDF Database

echo "🚀 Via di Francesco Database - Supabase Setup"
echo "============================================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
fi

# Function to update .env file
update_env() {
    local key="$1"
    local value="$2"
    
    if grep -q "^${key}=" .env; then
        # Update existing key
        sed -i '' "s|^${key}=.*|${key}=${value}|" .env
    else
        # Add new key
        echo "${key}=${value}" >> .env
    fi
}

echo "📋 Supabase Project Setup Instructions:"
echo ""
echo "1. Create a new Supabase project:"
echo "   - Project name: vdf-database"
echo "   - Database password: [Choose a strong password]"
echo "   - Region: [Choose closest to Italy/Europe]"
echo ""
echo "2. Once created, copy these values:"
echo "   - Project URL (from Settings > API)"
echo "   - Anon Key (from Settings > API)"
echo "   - Database Connection String (from Settings > Database)"
echo ""

# Prompt for values
read -p "Enter Supabase Project URL: " SUPABASE_URL
read -p "Enter Supabase Anon Key: " SUPABASE_ANON_KEY
read -p "Enter Database URL: " DATABASE_URL

# Update .env file
echo ""
echo "Updating .env file..."
update_env "SUPABASE_URL" "$SUPABASE_URL"
update_env "SUPABASE_ANON_KEY" "$SUPABASE_ANON_KEY"
update_env "DATABASE_URL" "$DATABASE_URL"

echo "✅ Environment variables updated!"
echo ""

# Initialize Supabase CLI
echo "Initializing Supabase CLI..."
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Please install it first:"
    echo "   npm install -g supabase"
    echo "   or"
    echo "   brew install supabase/tap/supabase"
    exit 1
fi

# Initialize project
if [ ! -d "supabase" ]; then
    echo "Running supabase init..."
    supabase init
fi

# Extract project ID from URL
PROJECT_ID=$(echo $SUPABASE_URL | sed -n 's|https://\([^.]*\)\.supabase\.co|\1|p')

if [ -n "$PROJECT_ID" ]; then
    echo ""
    echo "Linking to Supabase project..."
    supabase link --project-ref $PROJECT_ID
    
    echo ""
    echo "✅ Supabase project linked successfully!"
else
    echo "⚠️  Could not extract project ID. Please run manually:"
    echo "   supabase link --project-ref [YOUR_PROJECT_ID]"
fi

echo ""
echo "🎉 Setup complete! Next steps:"
echo "1. Run 'source .env' to load environment variables"
echo "2. Test connection with: psql \$DATABASE_URL -c 'SELECT 1'"
echo "3. Start implementing Module 1 migrations"