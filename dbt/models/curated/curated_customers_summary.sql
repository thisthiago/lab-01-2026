/*
  models/curated/curated_customers_summary.sql
  =============================================
  Sumarização de clientes com métricas de LTV e comportamento.
*/

with orders as (

    select * from {{ ref('stg_orders') }}

),

customers as (

    select * from {{ ref('stg_customers') }}

),

customer_metrics as (

    select
        customer_id,
        count(*)                                            as total_orders,
        count(*) filter (where order_status = 'completed') as completed_orders,
        count(*) filter (where order_status = 'cancelled') as cancelled_orders,
        sum(total_amount) filter (where order_status = 'completed') as total_revenue,
        avg(total_amount) filter (where order_status = 'completed') as avg_order_value,
        max(total_amount)                                   as max_order_value,
        min(order_created_at)                               as first_order_at,
        max(order_created_at)                               as last_order_at

    from orders
    group by customer_id

),

final as (

    select
        c.customer_id,
        c.customer_name,
        c.customer_email,
        c.customer_phone,
        c.segment,
        c.customer_created_at,

        -- Métricas de pedidos
        coalesce(m.total_orders, 0)     as total_orders,
        coalesce(m.completed_orders, 0) as completed_orders,
        coalesce(m.cancelled_orders, 0) as cancelled_orders,
        coalesce(m.total_revenue, 0)    as lifetime_value,
        m.avg_order_value,
        m.max_order_value,
        m.first_order_at,
        m.last_order_at,

        -- Taxa de conversão
        case
            when coalesce(m.total_orders, 0) = 0 then 0
            else round(
                coalesce(m.completed_orders, 0)::numeric
                / m.total_orders::numeric * 100, 2
            )
        end as conversion_rate_pct,

        -- Classificação RFM simplificada
        case
            when coalesce(m.total_revenue, 0) >= 3000 then 'champion'
            when coalesce(m.total_revenue, 0) >= 1000 then 'loyal'
            when coalesce(m.total_revenue, 0) >= 300  then 'potential'
            else                                            'new'
        end as rfm_segment,

        current_timestamp as _transformed_at

    from customers c
    left join customer_metrics m using (customer_id)

)

select * from final
