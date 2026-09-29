# Laboratorio 05 — Modelo físico de ventas

## 1. Grain de fact_sales

Una fila representa una línea de producto vendido dentro de una
transacción, asociada a una fecha, una tienda y un cliente.

quantity indica cuántas unidades de ese producto se vendieron en
la línea. Una fila no representa necesariamente una sola unidad.

Ejemplo: si la venta 1001 contiene Laptop, Mouse y Keyboard,
fact_sales tendrá tres filas. Si se venden dos teclados en una
misma línea, esa fila tendrá quantity = 2.

## 2. Identificación de la transacción

sale_id identifica la transacción y puede repetirse en varias
filas cuando una venta contiene distintos productos.
Por lo tanto, sale_id no es una clave única de cada fila.

El modelo de la guía no incluye un número de línea. Si el sistema
origen permite repetir un producto en líneas separadas de una
misma venta, será necesario incorporar un identificador de línea
para distinguirlas y controlar duplicados durante la carga.

## 3. Business keys y surrogate keys

product_id, customer_id y store_id representan identificadores
del sistema de origen.

product_key, customer_key y store_key son claves analíticas
utilizadas para relacionar las dimensiones con fact_sales.
Su generación se gestionará en la futura carga de datos;
este laboratorio no implementa generación automática ni SCD.

date_key identifica la fecha en la dimensión temporal.
Para los datos de prueba se utiliza el formato numérico AAAAMMDD.

## 4. Medidas

- quantity: aditiva; permite sumar unidades vendidas.
- sales_amount: aditiva bajo una moneda común; permite sumar importes.
- unit_price: no aditiva; sumar precios unitarios no produce
  un indicador empresarial útil.

## 5. Alcance físico

Se crearán cinco tablas Delta administradas dentro de workspace.gold:
dim_date, dim_product, dim_customer, dim_store y fact_sales.

Se utilizará USING DELTA sin LOCATION.
El esquema gold se preparará antes de crear las tablas.

Los changesets 001 y 002 se conservarán sin cambios.
Cada tabla nueva tendrá su propio changeset y rollback.