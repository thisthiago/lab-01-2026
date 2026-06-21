/*
  models/curated/curated_orders.sql
  ===================================
  Modelo curated de pedidos — dados enriquecidos e prontos para consumo.

  Origem: stg.stg_orders + stg.stg_customers
  Destino: table curated.curated_orders

  Transformações:
  - JOIN com clientes para enriquecimento
  - Cálculo de métricas derivadas
  - Categorização de pedidos por valor
  - Flags de negócio (is_completed, is_premium_customer)
*/

with orders as (

    select * from {{ ref('stg_orders') }}

),

customers as (

    select * from {{ ref('stg_customers') }}

),

enriched as (

    select
        -- Chaves
        o.order_id,
        o.customer_id,

        -- Dados do pedido
        o.order_status,
        o.total_amount,
        o.currency,
        o.shipping_city,
        o.shipping_state,
        o.shipping_zip,
        o.order_created_at,
        o.order_updated_at,

        -- Dados do cliente (enriquecimento via JOIN)
        c.customer_name,
        c.customer_email,
        c.phone          as customer_phone,
        c.segment        as customer_segment,
        c.customer_created_at,

        -- Métricas derivadas
        case
            when o.total_amount < 100   then 'baixo'
            when o.total_amount < 500   then 'medio'
            when o.total_amount < 2000  then 'alto'
            else                              'premium'
        end as ticket_categoria,

        -- Flags de negócio
        (o.order_status = 'completed')                  as is_completed,
        (o.order_status = 'cancelled')                  as is_cancelled,
        (c.segment = 'premium')                         as is_premium_customer,
        (o.total_amount >= 1000 and c.segment = 'premium') as is_vip_order,

        -- Tempo de processamento em horas
        extract(epoch from (o.order_updated_at - o.order_created_at)) / 3600
            as processing_hours,

        -- Metadados de auditoria
        o._extracted_at,
        current_timestamp as _transformed_at

    from orders o
    left join customers c on o.customer_id = c.customer_id

)

select * from enriched
