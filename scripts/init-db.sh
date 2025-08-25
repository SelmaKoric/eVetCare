#!/bin/bash

set -e

echo "Starting database initialization..."

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to be ready..."
until /opt/mssql-tools/bin/sqlcmd -S "$DB_SERVER" -U sa -P "$SA_PASSWORD" -Q "SELECT 1" &> /dev/null
do
  echo "SQL Server is not ready yet..."
  sleep 2
done

echo "SQL Server is ready!"

# Create database if it doesn't exist
echo "Creating database if it doesn't exist..."
/opt/mssql-tools/bin/sqlcmd -S "$DB_SERVER" -U sa -P "$SA_PASSWORD" -Q "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'eVetCare') CREATE DATABASE eVetCare;"

echo "Database created/verified!"

# Run migrations
echo "Running database migrations..."
dotnet ef database update --project /src/eVetCare.Services --startup-project /src/eVetCare --connection "Server=$DB_SERVER;Database=eVetCare;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=true;MultipleActiveResultSets=true"

echo "Database initialization completed!"
