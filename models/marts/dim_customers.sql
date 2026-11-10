{{ config(distributed_replicated=true) }}

select
    c.customer_id,
    c.registered_at,
    c.registration_date,
    c.city,
    c.acquisition_channel,
    p.first_confirmed_order_id,
    p.first_confirmed_at,
    coalesce(p.confirmed_orders_count, 0) as confirmed_orders_count,
    coalesce(p.confirmed_revenue, 0) as confirmed_revenue,
    coalesce(p.confirmed_orders_count, 0) > 0 as is_buyer
from {{ ref('stg_shop__customers') }} as c
left join {{ ref('int_customer_purchases') }} as p
    on c.customer_id = p.customer_id
