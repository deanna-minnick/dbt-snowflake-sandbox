with payments as (
    select * from {{ ref('stg_payments') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

payment_aggregations as (
    select 
        order_id,
        max(created_at) as payment_finalized_date,
        sum(payment_amount) as total_amount_paid
    from payments
    where payment_status <> 'fail'
    group by 1
    ),

paid_orders as (
    
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date as order_placed_at,
        orders.status as order_status,
        payment_aggregations.total_amount_paid,
        payment_aggregations.payment_finalized_date,
        customers.first_name as customer_first_name,
        customers.last_name as customer_last_name,
        row_number() over (order by payment_aggregations.order_id) as transaction_seq,
        row_number() over (partition by orders.customer_id order by payment_aggregations.order_id) as customer_sales_seq
from orders
left join payment_aggregations
    on orders.order_id = payment_aggregations.order_id
left join customers
    on orders.customer_id = customers.customer_id

),

customer_orders as (
    
    select
        customer_id,
        min(order_date) as fdos,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders
    from orders
group by 1

),

running_clv as (
    select
        p.order_id,
        sum(t2.total_amount_paid) as customer_lifetime_value
    from paid_orders p
    left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
    group by 1
    order by p.order_id
),

final as (
    select
        paid_orders.*,
        case when customer_orders.fdos = paid_orders.order_placed_at
            then 'new'
            else 'return'
            end as nvsr,
        running_clv.customer_lifetime_value,
        customer_orders.fdos
    from paid_orders
    left join customer_orders
        on paid_orders.customer_id = customer_orders.customer_id
    left outer join running_clv
        on running_clv.order_id = paid_orders.order_id
    order by order_id
)

select * from final