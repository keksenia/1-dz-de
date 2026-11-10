with orders as (
    select * from {{ ref('stg_shop__orders') }}
),

payments as (
    select * from {{ ref('stg_shop__payments') }}
),

order_payments as (
    select
        order_id,
        count(*) filter (where payment_status = 'success' and not is_refund)
                as successful_payments_count,
        coalesce(sum(amount) filter (where payment_status = 'success' and not is_refund), 0)
                as paid_amount,
        coalesce(-sum(amount) filter (where is_refund), 0)
                as refunded_amount,
        min(paid_at) filter (where payment_status = 'success' and not is_refund)
                as first_paid_at
    from payments
    group by order_id
),

order_items as (
    select
        order_id,
        count(distinct product_id) as items_count
    from {{ ref('stg_shop__order_items') }}
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    o.ordered_at,
    o.order_date,
    o.order_status,
    o.order_amount,
    o.is_test_order,
    coalesce(i.items_count, 0) as items_count,
    coalesce(p.successful_payments_count, 0) as successful_payments_count,
    coalesce(p.paid_amount, 0)               as paid_amount,
    coalesce(p.refunded_amount, 0)           as refunded_amount,
    coalesce(p.paid_amount, 0) - coalesce(p.refunded_amount, 0)
                                             as net_paid_amount,
    p.first_paid_at,
    o.order_status = 'paid' and coalesce(p.successful_payments_count, 0) > 0
                                             as is_confirmed
from orders as o
left join order_payments as p
    on p.order_id = o.order_id
left join order_items as i
    on i.order_id = o.order_id
