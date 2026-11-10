with raw_total as (
    select
        count(*) as orders_count,
        coalesce(sum(o.total_amount), 0) as revenue
    from {{ source('shop', 'orders') }} as o
    where o.status = 'paid'
      and exists (
          select 1
          from {{ source('shop', 'payments') }} as p
          where p.order_id = o.order_id
            and p.payment_status = 'success'
            and p.amount >= 0
      )
),

mart_total as (
    select
        count(*) as orders_count,
        coalesce(sum(order_amount), 0) as revenue
    from {{ ref('fct_orders') }}
    where is_confirmed
)

select
    r.orders_count as raw_orders_count,
    m.orders_count as mart_orders_count,
    r.revenue as raw_revenue,
    m.revenue as mart_revenue
from raw_total as r
cross join mart_total as m
where r.revenue <> m.revenue
   or r.orders_count <> m.orders_count
