
    
    

with all_values as (

    select
        order_status as value_field,
        count(*) as n_records

    from "datawarehouse"."public_stg"."stg_orders"
    group by order_status

)

select *
from all_values
where value_field not in (
    'pending','processing','completed','cancelled','refunded'
)


