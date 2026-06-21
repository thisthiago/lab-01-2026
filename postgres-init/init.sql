-- =============================================================
-- PostgreSQL Initialization Script
-- Executado automaticamente no primeiro boot do container
-- =============================================================

-- Schema para dados brutos extraídos pelo Airbyte
CREATE SCHEMA IF NOT EXISTS stg;

-- Schema para dados transformados pelo dbt
CREATE SCHEMA IF NOT EXISTS curated;

-- Garantir privilégios no schema stg
GRANT ALL PRIVILEGES ON SCHEMA stg TO dw_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA stg GRANT ALL ON TABLES TO dw_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA stg GRANT ALL ON SEQUENCES TO dw_user;

-- Garantir privilégios no schema curated
GRANT ALL PRIVILEGES ON SCHEMA curated TO dw_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA curated GRANT ALL ON TABLES TO dw_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA curated GRANT ALL ON SEQUENCES TO dw_user;

-- Comentários nos schemas
COMMENT ON SCHEMA stg IS 'Staging layer: dados brutos extraídos do MongoDB via Airbyte';
COMMENT ON SCHEMA curated IS 'Curated layer: dados transformados e prontos para consumo via dbt';

-- Log de inicialização
DO $$
BEGIN
    RAISE NOTICE '✅ Schemas stg e curated criados com sucesso no banco %', current_database();
END$$;
