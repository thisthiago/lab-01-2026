#!/bin/bash
# =============================================================
# Script que cria o banco dagster separado para o metadata storage
# O PostgreSQL executa scripts .sh do initdb como root do postgres
# =============================================================

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Criar banco separado para o Dagster
    SELECT 'CREATE DATABASE dagster OWNER $POSTGRES_USER'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'dagster')\gexec

    -- Garantir acesso
    GRANT ALL PRIVILEGES ON DATABASE dagster TO $POSTGRES_USER;
EOSQL

echo "✅ Banco de dados 'dagster' criado para metadata storage"
