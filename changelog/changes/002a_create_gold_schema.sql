--liquibase formatted sql

--changeset estudiante:002a
CREATE SCHEMA IF NOT EXISTS workspace.gold
COMMENT 'Capa Gold - Modelo dimensional UCV Retail';

--rollback DROP SCHEMA IF EXISTS workspace.gold;