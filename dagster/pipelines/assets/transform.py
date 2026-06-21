"""
assets/transform.py
===================
Assets de transformação de dados via dbt.

Após a extração (Airbyte → stg), o dbt transforma os dados:
  PostgreSQL stg ──[dbt run]──► PostgreSQL curated

O dagster-dbt converte automaticamente cada model dbt em um
Software-Defined Asset no Dagster, com linhagem completa.
"""

import os
from pathlib import Path

from dagster import AssetExecutionContext
from dagster_dbt import DbtCliResource, DbtProject, dbt_assets


# =============================================================
# CONFIGURAÇÃO DO PROJETO dbt
# =============================================================
DBT_PROJECT_DIR = Path("/opt/dagster/dbt")

dbt_project = DbtProject(
    project_dir=DBT_PROJECT_DIR,
    packaged_project_dir=DBT_PROJECT_DIR,
)

# Preparar o projeto dbt (gera manifest.json se necessário)
dbt_project.prepare_if_dev()


# =============================================================
# ASSETS dbt — Carrega automaticamente todos os modelos dbt
# como assets do Dagster com dependências declaradas
# =============================================================
@dbt_assets(
    manifest=dbt_project.manifest_path,
    project=dbt_project,
    name="dbt_models",
)
def dbt_lab_assets(
    context: AssetExecutionContext,
    dbt: DbtCliResource,
):
    """
    Executa todos os modelos dbt do projeto.
    Cada model dbt (staging e curated) aparece como um asset separado
    no grafo do Dagster com dependências automáticas.
    """
    yield from dbt.cli(["build"], context=context).stream()
