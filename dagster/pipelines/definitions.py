"""
definitions.py
==============
Ponto de entrada principal do Dagster.
Define todos os assets, resources, jobs e schedules do pipeline.

Fluxo completo:
  MongoDB ──[Airbyte]──► PostgreSQL stg ──[dbt]──► PostgreSQL curated
                             ↑                            ↑
                    Asset: mongodb_to_postgres_stg    Assets: dbt_models
"""

import os
from pathlib import Path

import dagster as dg
from dagster import (
    AssetSelection,
    DefaultScheduleStatus,
    Definitions,
    ScheduleDefinition,
    define_asset_job,
    load_assets_from_modules,
)
from dagster_airbyte import AirbyteResource
from dagster_dbt import DbtCliResource, DbtProject

from pipelines.assets import extract, transform
from pipelines.assets.extract import mongodb_to_postgres_stg
from pipelines.assets.transform import dbt_lab_assets

# =============================================================
# RESOURCES
# =============================================================
airbyte_resource = AirbyteResource(
    host=os.getenv("AIRBYTE_HOST", "airbyte-server"),
    port=os.getenv("AIRBYTE_PORT", "8001"),
    username=os.getenv("BASIC_AUTH_USERNAME", "airbyte"),
    password=os.getenv("BASIC_AUTH_PASSWORD", "password"),
    use_https=False,
    request_timeout=600,
)

dbt_resource = DbtCliResource(
    project_dir=Path("/opt/dagster/dbt"),
    profiles_dir=Path("/opt/dagster/dbt"),
    target="prod",
)

# =============================================================
# ASSETS
# =============================================================
all_assets = [
    mongodb_to_postgres_stg,  # Extração: MongoDB → stg
    dbt_lab_assets,           # Transformação: stg → curated
]

# =============================================================
# JOBS
# =============================================================
# Job completo: extração + transformação
pipeline_completo = define_asset_job(
    name="pipeline_completo",
    selection=AssetSelection.all(),
    description="Pipeline completo: Airbyte sync (MongoDB→stg) + dbt build (stg→curated)",
)

# Job apenas extração (Airbyte)
job_extracao = define_asset_job(
    name="job_extracao",
    selection=AssetSelection.assets(mongodb_to_postgres_stg),
    description="Apenas extração via Airbyte: MongoDB → PostgreSQL stg",
)

# Job apenas transformação (dbt)
job_transformacao = define_asset_job(
    name="job_transformacao",
    selection=AssetSelection.assets(dbt_lab_assets),
    description="Apenas transformação via dbt: stg → curated",
)

# =============================================================
# SCHEDULES
# =============================================================
# Pipeline completo rodando diariamente às 06:00
schedule_diario = ScheduleDefinition(
    name="schedule_pipeline_diario",
    job=pipeline_completo,
    cron_schedule="0 6 * * *",          # Todo dia às 06:00
    default_status=DefaultScheduleStatus.STOPPED,  # Ativado manualmente
    description="Executa o pipeline completo diariamente às 06:00",
)

# =============================================================
# DEFINITIONS — Ponto de entrada do Dagster
# =============================================================
defs = Definitions(
    assets=all_assets,
    resources={
        "airbyte": airbyte_resource,
        "dbt": dbt_resource,
    },
    jobs=[
        pipeline_completo,
        job_extracao,
        job_transformacao,
    ],
    schedules=[
        schedule_diario,
    ],
)
