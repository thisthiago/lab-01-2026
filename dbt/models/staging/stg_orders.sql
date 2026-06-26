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

    select * from {{ source('airbyte_raw', 'orders') }}

),

renamed as (

    select
        -- Chaves
        order_id,
        customer_id,

        -- Dados do cliente
        customer_name,
        customer_email,

        -- Status e valores
        status           as order_status,
        total_amount::numeric(12, 2) as total_amount,
        currency,

        -- Endereço de entrega (JSONB aninhado)
        shipping_address->>'city'  as shipping_city,
        shipping_address->>'state' as shipping_state,
        shipping_address->>'zip'   as shipping_zip,

        -- Itens do pedido (mantido como JSONB para curated processar)
        items as items_raw,

        -- Timestamps
        created_at::timestamp as order_created_at,
        updated_at::timestamp as order_updated_at,

        -- Metadados Airbyte
        _airbyte_emitted_at as _extracted_at,
        current_timestamp   as _loaded_at

    from source

)

select * from renamed
