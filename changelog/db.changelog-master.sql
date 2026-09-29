--liquibase formatted sql

--changeset estudiante:001
CREATE SCHEMA IF NOT EXISTS workspace.bi_lab_7002617842
COMMENT 'Laboratorio 02 - BI y Big Data - UCV';

--rollback DROP SCHEMA IF EXISTS workspace.bi_lab_7002617842;

--changeset estudiante:002
CREATE SCHEMA IF NOT EXISTS workspace.bi_staging_7002617842
COMMENT 'Staging schema - BI and Big Data - Lab 03';

--rollback DROP SCHEMA IF EXISTS workspace.bi_staging_7002617842;