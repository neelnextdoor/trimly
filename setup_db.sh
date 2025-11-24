#!/bin/bash

# Database Setup Script for Barber Application
# Reads MySQL credentials from .env file

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "❌ Error: .env file not found!"
    exit 1
fi

echo "Setting up barber database..."
echo "Using MySQL credentials from .env file..."
echo ""

mysql -h ${DB_HOST:-localhost} -P ${DB_PORT:-3306} -u ${DB_USER:-root} -p${DB_PASS} < setup_database.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Database setup completed successfully!"
    echo "Database 'barber' has been created with all tables and seed data."
else
    echo ""
    echo "❌ Database setup failed. Please check the error messages above."
    exit 1
fi

