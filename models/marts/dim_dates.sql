{{ config(distributed_replicated=true) }}

select
    order_date,
    extract(year from order_date)::integer as year,
    extract(quarter from order_date)::integer as quarter,
    extract(month from order_date)::integer as month,
    extract(isodow from order_date)::integer as day_of_week,
    extract(isodow from order_date) in (6, 7) as is_weekend
from {{ ref('int_calendar') }}
