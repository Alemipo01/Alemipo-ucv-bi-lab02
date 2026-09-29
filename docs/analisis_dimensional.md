# Laboratorio 04 — Modelo dimensional de UCV Retail

## 1. Proceso de negocio

El proceso seleccionado es VENTAS.

La gerencia necesita analizar los importes y las cantidades vendidas
según el tiempo, los productos, las tiendas y los clientes.
Un modelo dimensional permite relacionar estas mediciones con el
contexto necesario para apoyar decisiones comerciales.

## 2. Alcance

Se diseña un modelo lógico de ventas para la capa Gold.
Este laboratorio no crea tablas físicas ni modifica los changesets
001 y 002 de los laboratorios anteriores.

## 3. Matriz de preguntas analíticas

| ID | Pregunta analítica | Métrica y cálculo | Dimensiones y nivel de análisis | Decisión que apoya |
|---|---|---|---|---|
| Q01 | ¿Cuál es el importe total vendido por mes de cada año? | SUM(sales_amount) | Tiempo: año y mes | Identificar tendencias y planificar campañas estacionales. |
| Q02 | ¿Cuál es el importe vendido por tienda y ciudad durante cada mes? | SUM(sales_amount) | Tienda: ciudad y tienda; tiempo: año y mes | Comparar establecimientos y priorizar acciones comerciales. |
| Q03 | ¿Qué productos tienen más unidades vendidas durante cada trimestre? | SUM(quantity) | Producto: producto; tiempo: año y trimestre | Priorizar la reposición de productos con mayor demanda. |
| Q04 | ¿Cuál es el ticket promedio por tienda durante cada mes? | SUM(sales_amount) / número de tickets distintos | Tienda: tienda; tiempo: año y mes | Evaluar oportunidades de venta complementaria. |
| Q05 | ¿Cuál es el importe vendido por segmento de cliente durante cada trimestre? | SUM(sales_amount) | Cliente: segmento; tiempo: año y trimestre | Diseñar campañas dirigidas a cada segmento. |
| Q06 | ¿Qué categorías generan mayores ingresos por región durante cada trimestre? | SUM(sales_amount) | Producto: categoría; tienda: región; tiempo: año y trimestre | Ajustar el surtido comercial por región. |
| Q07 | ¿Qué clientes acumulan mayor importe de compras durante cada año? | SUM(sales_amount) | Cliente: identificador y nombre; tiempo: año | Identificar clientes para programas de fidelización. |
| Q08 | ¿Cuál es el importe vendido por categoría, ciudad, trimestre y segmento de cliente? | SUM(sales_amount) | Producto: categoría; tienda: ciudad; tiempo: año y trimestre; cliente: segmento | Adaptar campañas y surtido a cada mercado y segmento. |

## 4. Consideración sobre el ticket promedio

El modelo inicial de la guía no incluye un identificador de ticket.

Por eso, Q04 requiere incorporar posteriormente un identificador de
transacción que permita contar tickets distintos. No se debe calcular
el ticket promedio contando filas de fact_sales, porque un ticket puede
contener varias líneas de productos.

En este laboratorio se conserva el modelo lógico propuesto por la guía
y se documenta esta necesidad para el diseño físico de la siguiente sesión.

## 5. Hechos y medidas

La tabla de hechos propuesta es fact_sales.

Como supuesto de trabajo, cada registro representa una línea de producto
vendida en una transacción. El grano definitivo y las claves que identifiquen
cada línea se precisarán en el Laboratorio 05.

| Campo | Clasificación | Justificación |
|---|---|---|
| quantity | Medida aditiva | Representa las unidades vendidas y se puede sumar para obtener volúmenes de venta. |
| unit_price | Medida no aditiva | Representa el precio unitario aplicado. Sumar precios no produce un indicador útil. |
| sales_amount | Medida aditiva | Representa el importe de la línea de venta y permite calcular ingresos por distintas dimensiones. |
| date_key | Referencia a dimensión | Relaciona la venta con su fecha. |
| product_key | Referencia a dimensión | Identifica el producto vendido. |
| store_key | Referencia a dimensión | Identifica la tienda de la venta. |
| customer_key | Referencia a dimensión | Identifica al cliente asociado a la venta. |

Para este caso académico se asume una misma moneda y ventas sin
descuentos ni devoluciones. Bajo ese supuesto:
sales_amount = quantity × unit_price.

El precio unitario promedio ponderado se obtiene con
SUM(sales_amount) / SUM(quantity), siempre que la cantidad total
sea distinta de cero. Este indicador no equivale al ticket promedio.

## 6. Dimensiones y atributos

Las dimensiones describen el contexto de las ventas:
cuándo ocurrieron, qué producto se vendió, dónde y a quién.

| Dimensión | Atributos | Utilidad analítica |
|---|---|---|
| dim_date | date_key, full_date, day, month, month_name, quarter, year | Analizar tendencias y comparar periodos. |
| dim_product | product_key, product_id, product_name, brand, subcategory, category | Comparar productos, marcas y categorías. |
| dim_store | store_key, store_id, store_name, city, region, country | Analizar el desempeño de tiendas y ubicaciones. |
| dim_customer | customer_key, customer_id, customer_name, segment, city, country | Analizar clientes y segmentos comerciales. |

Las claves con sufijo _key identifican los registros de las dimensiones.
Los campos product_id, store_id y customer_id representan identificadores
del negocio. Su implementación física se definirá posteriormente.

Para las preguntas sobre ciudad y región de venta se utiliza dim_store.
La ciudad del cliente describe su ubicación y no necesariamente coincide
con la ubicación de la tienda.

## 7. Jerarquías de análisis

| Dimensión | Jerarquía desde mayor agregación hacia mayor detalle |
|---|---|
| Tiempo | Año → Trimestre → Mes → Día |
| Producto | Categoría → Subcategoría → Producto |
| Ubicación de la tienda | País → Región → Ciudad → Tienda |

Se asume que cada producto pertenece a una subcategoría y cada
subcategoría a una categoría. Cada tienda pertenece a una ciudad,
región y país.

Los meses se identifican junto con su año para no mezclar, por ejemplo,
enero de años distintos. Las ciudades se interpretan dentro de su
región y país para evitar confundir ubicaciones con nombres iguales.

### Navegación de Q01

Para analizar el importe vendido por mes, la gerencia puede partir del
total anual, bajar al trimestre, después al mes y finalmente al día.
Esto es drill-down.

El recorrido inverso, de día a mes, trimestre y año, es roll-up.

### Navegación de Q06

Para analizar ingresos por categoría y región, se puede bajar desde
categoría a subcategoría y producto. En ubicación, se puede bajar
desde región a ciudad y tienda.

Esto permite identificar qué productos y establecimientos explican
el resultado agregado. El roll-up permite volver a resumir las ventas
por categoría o región.

## 8. Diseño del esquema estrella

fact_sales es la tabla central. Se relaciona directamente con
dim_date, dim_product, dim_store y dim_customer.

Cada dimensión tiene una relación de uno a muchos con fact_sales:

- dim_date 1 → N fact_sales
- dim_product 1 → N fact_sales
- dim_store 1 → N fact_sales
- dim_customer 1 → N fact_sales

Una misma fecha, producto, tienda o cliente puede aparecer en muchas
líneas de venta. Cada línea de venta se relaciona con un registro
de cada dimensión, bajo el supuesto de referencias válidas.

Las dimensiones contienen los atributos descriptivos y la tabla de
hechos contiene las referencias y las medidas de la transacción.

## 9. Comparación de modelos

| Modelo | Aplicación al caso UCV Retail | Ventaja | Consideración |
|---|---|---|---|
| Star | fact_sales conectada directamente con las cuatro dimensiones. Categoría y subcategoría permanecen en dim_product. | Consultas analíticas sencillas y menos uniones. | Se repiten algunos atributos descriptivos. |
| Snowflake | Categoría y subcategoría podrían separarse en tablas relacionadas con producto. | Reduce redundancia en esos atributos. | Requiere más uniones y hace más compleja la navegación. |
| Constellation | fact_sales y fact_inventory comparten dimensiones de fecha, producto y tienda. | Permite analizar ventas e inventario con un contexto común. | Requiere definir el grano de cada hecho y mantener dimensiones consistentes. |

Se elige Star como diseño principal por su simplicidad para responder
las preguntas comerciales del laboratorio.

### Propuesta conceptual de inventario

fact_inventory representaría una observación diaria del inventario
por producto y tienda. Compartiría dim_date, dim_product y dim_store
con fact_sales.

Una medida posible sería stock_quantity. Se podría sumar entre
productos y tiendas para una fecha determinada, pero no sumar
indiscriminadamente entre días porque se contarían existencias repetidas.

Esta propuesta es conceptual y no se implementa en el DBML principal.

## 10. Unity Catalog y capa Gold

El namespace propuesto por la guía es:

- ucv_bi.gold.dim_date
- ucv_bi.gold.dim_product
- ucv_bi.gold.dim_store
- ucv_bi.gold.dim_customer
- ucv_bi.gold.fact_sales

ucv_bi representa el catálogo, gold el esquema y el último componente
identifica la tabla.

Esta propuesta no implica que el catálogo ucv_bi o el esquema gold
ya existan. En los laboratorios anteriores se utilizó workspace;
la ubicación física definitiva se establecerá en la implementación.

El modelo pertenece a Gold porque organiza datos transformados e
integrados para el análisis de negocio y el consumo desde herramientas
de BI. Sus dimensiones, medidas y jerarquías facilitan indicadores
y comparaciones consistentes.

Bronze conserva los datos crudos de origen y Silver contiene datos
limpios e integrados. Gold presenta una estructura orientada a las
preguntas analíticas de la gerencia.

## 11. Desafío integrador

Para conocer el importe de ventas por categoría, ciudad, trimestre
y segmento de cliente se utilizaría:

| Elemento | Selección |
|---|---|
| Tabla de hechos | fact_sales |
| Medida | SUM(sales_amount) |
| Dimensión de producto | dim_product, nivel category |
| Dimensión de ubicación | dim_store, nivel city dentro de su región y país |
| Dimensión temporal | dim_date, niveles year y quarter |
| Dimensión de cliente | dim_customer, atributo segment |
| Namespace de la tabla de hechos | ucv_bi.gold.fact_sales |

La consulta agruparía el importe por esos atributos. Si el resultado
se publicara posteriormente como una vista analítica, una ubicación
conceptual sería ucv_bi.gold.vw_sales_analysis.

No se crea esa vista ni ninguna tabla física en este laboratorio.