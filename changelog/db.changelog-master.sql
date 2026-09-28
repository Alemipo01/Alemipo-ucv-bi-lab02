--liquibase formatted sql

--changeset estudiante:001
CREATE SCHEMA IF NOT EXISTS workspace.bi_lab_7002617842
COMMENT 'Laboratorio 02 - BI y Big Data - UCV';

--rollback DROP SCHEMA IF EXISTS workspace.bi_lab_7002617842;