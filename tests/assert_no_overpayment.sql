{{ config(severity='warn') }}

select
    order_id,
    order_amount,
    paid_amount,
    paid_amount - order_amount as overpaid_amount
from {{ ref('fct_orders') }}
where is_confirmed
  and paid_amount > order_amount
