/*
  models/staging/stg_customers.sql
  ==================================
  Modelo de staging para a coleção 'customers' do MongoDB.
*/

with source as (

    select * from "datawarehouse"."stg"."customers"

),

renamed as (

    select
        _airbyte_data->>'customer_id'   as customer_id,
        _airbyte_data->>'name'          as customer_name,
        _airbyte_data->>'email'         as customer_email,
        _airbyte_data->>'phone'         as phone,
        _airbyte_data->>'segment'       as segment,
        (_airbyte_data->>'created_at')::timestamp as customer_created_at,

        -- Metadados
        _airbyte_extracted_at as _extracted_at,
        current_timestamp      as _loaded_at

    from source

)

select * from renamed