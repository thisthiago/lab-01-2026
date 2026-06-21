
    
    

with all_values as (

    select
        rfm_segment as value_field,
        count(*) as n_records

    from "datawarehouse"."public_curated"."curated_customers_summary"
    group by rfm_segment

)

select *
from all_values
where value_field not in (
    'champion','loyal','potential','new'
)


