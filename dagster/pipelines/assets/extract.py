"""
assets/extract.py
=================
Assets de extração de dados via integração Airbyte.

O Dagster se conecta ao Airbyte via REST API (porta 8001) e dispara
o sync da connection MongoDB → PostgreSQL stg.

Fluxo:
  MongoDB (source_db) ──[Airbyte sync]──► PostgreSQL (schema: stg)
"""

import os
from dagster import (
    AssetExecutionContext,
    asset,
)
from dagster_airbyte import AirbyteResource


# =============================================================
# RESOURCE: Conexão com o Airbyte OSS (self-hosted)
# Usado via Definitions em definitions.py
# =============================================================
def get_airbyte_resource() -> AirbyteResource:
    return AirbyteResource(
        host=os.getenv("AIRBYTE_HOST", "airbyte-server"),
        port=os.getenv("AIRBYTE_PORT", "8001"),
        username=os.getenv("BASIC_AUTH_USERNAME", "airbyte"),
        password=os.getenv("BASIC_AUTH_PASSWORD", "password"),
        use_https=False,
        request_timeout=600,  # 10 min timeout para syncs grandes
    )


# =============================================================
# ASSET: Sync MongoDB → PostgreSQL stg (via Airbyte)
#
# IMPORTANTE: O connection_id abaixo deve ser preenchido após
# criar a connection no Airbyte UI (http://localhost:8000).
# Consulte o README.md para o passo-a-passo.
# =============================================================
AIRBYTE_CONNECTION_ID = os.getenv(
    "AIRBYTE_CONNECTION_ID",
    "00000000-0000-0000-0000-000000000000",  # substituir após criar no UI
)


@asset(
    name="mongodb_to_postgres_stg",
    group_name="extract",
    description=(
        "Dispara o sync do Airbyte: MongoDB source_db → PostgreSQL schema stg. "
        "Extrai as coleções 'orders' e 'customers' e carrega nas tabelas stg.orders e stg.customers."
    ),
    metadata={
        "source": "MongoDB",
        "destination": "PostgreSQL (schema: stg)",
        "tool": "Airbyte",
        "connection_id": AIRBYTE_CONNECTION_ID,
    },
)
def mongodb_to_postgres_stg(
    context: AssetExecutionContext,
    airbyte: AirbyteResource,
) -> None:
    """
    Materializa o asset disparando o sync do Airbyte.
    O Dagster aguarda a conclusão e reporta o status aqui na UI.
    """
    context.log.info(
        f"🚀 Iniciando sync Airbyte | connection_id={AIRBYTE_CONNECTION_ID}"
    )

    if AIRBYTE_CONNECTION_ID == "00000000-0000-0000-0000-000000000000":
        context.log.warning(
            "⚠️  AIRBYTE_CONNECTION_ID não configurado! "
            "Crie a connection no Airbyte UI e configure a variável de ambiente. "
            "Consulte o README.md para o passo-a-passo."
        )
        return

    # Disparar o sync via API do Airbyte e aguardar conclusão
    outcome = airbyte.sync_and_poll(
        connection_id=AIRBYTE_CONNECTION_ID,
        poll_interval=10,
        poll_timeout=600,
    )

    context.log.info(
        f"✅ Sync concluído | status={outcome.run_details}"
    )
