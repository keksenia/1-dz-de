with dates as (
    select
        min(order_date) as first_date,
        max(order_date) as last_date
    from {{ ref('stg_shop__orders') }}
)

select generate_series(
    first_date::timestamp,
    last_date::timestamp,
    interval '1 day'
)::date as order_date
from dates
