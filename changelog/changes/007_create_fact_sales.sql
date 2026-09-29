--liquibase formatted sql

--changeset estudiante:007
CREATE TABLE IF NOT EXISTS workspace.gold.fact_sales (
    sale_id BIGINT,
    date_key INT,
    product_key BIGINT,
    store_key BIGINT,
    customer_key BIGINT,
    quantity INT,
    unit_price DECIMAL(12,2),
    sales_amount DECIMAL(14,2)
)
USING DELTA;

--rollback DROP TABLE IF EXISTS workspace.gold.fact_sales;