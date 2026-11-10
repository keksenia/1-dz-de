with source as (
    select * from {{ source('shop', 'order_items') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['order_id', 'product_id']) }} as order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_amount,
    quantity * unit_price           as gross_amount,
    quantity * unit_price - discount_amount as line_amount
from source
