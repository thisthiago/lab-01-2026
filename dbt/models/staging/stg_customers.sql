/*
  models/staging/stg_customers.sql
  ==================================
  Modelo de staging para a coleção 'customers' do MongoDB.
*/

with source as (

    select * from {{ source('airbyte_raw', 'customers') }}

),

renamed as (

    select
        customer_id,
        name            as customer_name,
        email           as customer_email,
        phone,
        segment,
        created_at::timestamp as customer_created_at,

        -- Metadados
        _airbyte_emitted_at as _extracted_at,
        current_timestamp   as _loaded_at

    from source

)

select * from renamed
