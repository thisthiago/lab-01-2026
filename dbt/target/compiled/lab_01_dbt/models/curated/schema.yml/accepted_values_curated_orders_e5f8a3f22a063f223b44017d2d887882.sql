
    
    

with all_values as (

    select
        ticket_categoria as value_field,
        count(*) as n_records

    from "datawarehouse"."public_curated"."curated_orders"
    group by ticket_categoria

)

select *
from all_values
where value_field not in (
    'baixo','medio','alto','premium'
)


