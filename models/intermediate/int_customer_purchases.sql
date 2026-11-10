with purchases as (
    select
        order_id,
        customer_id,
        first_paid_at,
        order_amount,
        row_number() over (
            partition by customer_id
            order by first_paid_at, order_id
        ) as purchase_number
    from {{ ref('int_orders_with_payments') }}
    where is_confirmed
),

totals as (
    select
        customer_id,
        count(*) as confirmed_orders_count,
        sum(order_amount) as confirmed_revenue
    from purchases
    group by customer_id
)

select
    p.customer_id,
    p.order_id as first_confirmed_order_id,
    p.first_paid_at as first_confirmed_at,
    t.confirmed_orders_count,
    t.confirmed_revenue
from purchases as p
join totals as t
    on p.customer_id = t.customer_id
where p.purchase_number = 1
