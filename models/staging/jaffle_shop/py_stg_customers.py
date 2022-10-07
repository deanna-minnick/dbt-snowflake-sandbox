def model(dbt, session):

    dbt.config(materialized = "table")

    stg_customers = dbt.source("jaffle_shop", "customers")

    renamed = {"id": "customer_id"}

    for col_name in renamed:
        stg_customers = stg_customers.rename(stg_customers[col_name], renamed[col_name])

    ##final = upstream_source.rename(columns=renamed)
    
    return stg_customers