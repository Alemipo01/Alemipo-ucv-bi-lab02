--liquibase formatted sql

--changeset estudiante:006
CREATE TABLE IF NOT EXISTS workspace.gold.dim_store (
    store_key BIGINT,
    store_id BIGINT,
    store_name STRING,
    city STRING,
    region STRING,
    country STRING
)
USING DELTA;

--rollback DROP TABLE IF EXISTS workspace.gold.dim_store;