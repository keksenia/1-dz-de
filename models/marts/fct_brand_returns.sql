{{ config(distributed_by='brand_date_id') }}

with brand_orders as (

    select distinct
        o.order_id,
        o.order_date,
        p.brand,
        o.order_status
    from {{ ref('fct_order_items') }} as i
    join {{ ref('fct_orders') }} as o
        on i.order_id = o.order_id
    join {{ ref('dim_products') }} as p
        on i.product_id = p.product_id
    where o.is_confirmed or o.order_status = 'returned'
),

daily as (
    select
        order_date,
        brand,
        count(*) as orders_count,
        count(*) filter (where order_status = 'returned') as returned_orders_count
    from brand_orders
    group by order_date, brand
)

select
    {{ dbt_utils.generate_surrogate_key(['order_date', 'brand']) }} as brand_date_id,
    order_date,
    brand,
    orders_count,
    returned_orders_count,
    returned_orders_count::numeric / orders_count as return_rate
from daily
