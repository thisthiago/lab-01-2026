.PHONY: up down logs ps restart reset build airbyte-logs dagster-logs dbt-run validate

# =============================================================
# Stack Control
# =============================================================

## Subir toda a stack
up:
	docker compose up -d

## Subir reconstruindo as imagens
up-build:
	docker compose up -d --build

## Parar todos os containers
down:
	docker compose down

## Parar e remover volumes (reset completo)
reset:
	docker compose down -v
	@echo "⚠️  Todos os dados foram removidos."

## Ver status dos serviços
ps:
	docker compose ps

## Ver logs de todos os serviços
logs:
	docker compose logs -f

# =============================================================
# Logs individuais
# =============================================================

airbyte-logs:
	docker compose logs -f airbyte-server airbyte-worker

dagster-logs:
	docker compose logs -f dagster-code dagster-webserver dagster-daemon

postgres-logs:
	docker compose logs -f postgres

mongo-logs:
	docker compose logs -f mongodb

# =============================================================
# Dagster — Pipeline Control
# =============================================================

## Rodar pipeline completo (extração + transformação)
run-pipeline:
	docker exec dagster-webserver dagster job execute \
		-f /opt/dagster/app/pipelines/definitions.py \
		-j pipeline_completo

## Rodar apenas a extração (Airbyte)
run-extract:
	docker exec dagster-webserver dagster job execute \
		-f /opt/dagster/app/pipelines/definitions.py \
		-j job_extracao

## Rodar apenas a transformação (dbt)
run-transform:
	docker exec dagster-webserver dagster job execute \
		-f /opt/dagster/app/pipelines/definitions.py \
		-j job_transformacao

# =============================================================
# dbt
# =============================================================

## Rodar dbt run dentro do container
dbt-run:
	docker exec dagster-code dbt run --project-dir /opt/dagster/dbt --profiles-dir /opt/dagster/dbt

## Rodar dbt test
dbt-test:
	docker exec dagster-code dbt test --project-dir /opt/dagster/dbt --profiles-dir /opt/dagster/dbt

## Instalar pacotes dbt
dbt-deps:
	docker exec dagster-code dbt deps --project-dir /opt/dagster/dbt --profiles-dir /opt/dagster/dbt

## Gerar documentação dbt
dbt-docs:
	docker exec dagster-code dbt docs generate --project-dir /opt/dagster/dbt --profiles-dir /opt/dagster/dbt

# =============================================================
# Validação de dados
# =============================================================

## Ver dados na camada stg
validate-stg:
	docker exec postgres psql -U dw_user -d datawarehouse \
		-c "SELECT order_id, customer_name, order_status, total_amount FROM stg.stg_orders LIMIT 10;"

## Ver dados na camada curated
validate-curated:
	docker exec postgres psql -U dw_user -d datawarehouse \
		-c "SELECT order_id, customer_name, ticket_categoria, is_vip_order FROM curated.curated_orders;"

## Ver sumário de clientes
validate-customers:
	docker exec postgres psql -U dw_user -d datawarehouse \
		-c "SELECT customer_name, total_orders, lifetime_value, rfm_segment FROM curated.curated_customers_summary;"

## Conectar ao psql interativo
psql:
	docker exec -it postgres psql -U dw_user -d datawarehouse

## Conectar ao MongoDB interativo
mongo:
	docker exec -it mongodb mongosh -u mongo_user -p mongo_password123 --authenticationDatabase admin source_db

# =============================================================
# Restart individual
# =============================================================

restart-dagster:
	docker compose restart dagster-code dagster-webserver dagster-daemon

restart-airbyte:
	docker compose restart airbyte-server airbyte-worker airbyte-webapp
