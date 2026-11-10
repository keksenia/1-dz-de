with expected as (
    select
        o.order_date,
        p.brand,
        count(distinct o.order_id) as orders_count,
        count(distinct case when o.order_status = 'returned' then o.order_id end)
            as returned_orders_count
    from {{ ref('fct_order_items') }} as i
    join {{ ref('fct_orders') }} as o
        on i.order_id = o.order_id
    join {{ ref('dim_products') }} as p
        on i.product_id = p.product_id
    where o.is_confirmed or o.order_status = 'returned'
    group by o.order_date, p.brand
),

actual as (
    select * from {{ ref('fct_brand_returns') }}
)

select e.order_date, e.brand
from expected as e
left join actual as a
    on e.order_date = a.order_date and e.brand = a.brand
where a.orders_count is distinct from e.orders_count
   or a.returned_orders_count is distinct from e.returned_orders_count
   or a.return_rate is distinct from e.returned_orders_count::numeric / e.orders_count

union all

select a.order_date, a.brand
from actual as a
left join expected as e
    on a.order_date = e.order_date and a.brand = e.brand
where e.order_date is null
