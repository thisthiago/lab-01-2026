/*
  models/staging/stg_orders.sql
  ==============================
  Modelo de staging para a coleção 'orders' do MongoDB.

  Origem: tabela stg.orders (carregada pelo Airbyte)
  Destino: view stg.stg_orders

  Realiza limpeza e padronização mínima dos dados brutos:
  - Renomeia colunas para snake_case padronizado
  - Faz cast de tipos
  - Adiciona coluna de controle _loaded_at
  
  Nota: O Airbyte carrega os dados do MongoDB com prefixo _airbyte_
  nas colunas de controle. Os dados reais ficam em _airbyte_data (JSONB).
*/

with source as (

    select * from "datawarehouse"."stg"."orders"

),

renamed as (

    select
        -- Chaves
        _airbyte_data->>'order_id'      as order_id,
        _airbyte_data->>'customer_id'   as customer_id,

        -- Dados do cliente
        _airbyte_data->>'customer_name'  as customer_name,
        _airbyte_data->>'customer_email' as customer_email,

        -- Status e valores
        _airbyte_data->>'status'         as order_status,
        (_airbyte_data->>'total_amount')::numeric(12, 2) as total_amount,
        _airbyte_data->>'currency'        as currency,

        -- Endereço de entrega (JSONB aninhado)
        _airbyte_data->'shipping_address'->>'city'  as shipping_city,
        _airbyte_data->'shipping_address'->>'state' as shipping_state,
        _airbyte_data->'shipping_address'->>'zip'   as shipping_zip,

        -- Itens do pedido (mantido como JSONB para curated processar)
        _airbyte_data->'items' as items_raw,

        -- Timestamps
        (_airbyte_data->>'created_at')::timestamp as order_created_at,
        (_airbyte_data->>'updated_at')::timestamp as order_updated_at,

        -- Metadados Airbyte
        _airbyte_extracted_at as _extracted_at,
        current_timestamp      as _loaded_at

    from source

)

select * from renamed