{{ config(distributed_replicated=true) }}

select
    p.product_id,
    p.product_name,
    p.brand,
    p.category_name,
    c.parent_category_name,
    c.root_category_name
from {{ ref('stg_shop__products') }} as p
left join {{ ref('int_product_category_tree') }} as c
    on p.category_name = c.category_name
