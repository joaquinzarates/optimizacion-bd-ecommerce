<a id="readme-top"></a>

[![SQL Server][sqlserver-shield]][sqlserver-url]
[![SSMS][ssms-shield]][ssms-url]
[![License][license-shield]][license-url]

# Optimización de Base de Datos : E-Commerce

Proyecto para validar los conocimientos obtenidos en el Track: Bases de Datos para Web, mediante la construcción, poblado y optimización de una base de datos de un e-commerce 

<details>
  <summary>Tabla de contenidos</summary>
  <ol>
    <li><a href="#tecnologías-utilizadas">Tecnologías utilizadas</a></li>
    <li><a href="#estructura-del-repositorio">Estructura del repositorio</a></li>
    <li><a href="#cómo-ejecutar">Cómo ejecutar</a></li>
    <li><a href="#estructura-de-la-base-de-datos">Estructura de la base de datos</a></li>
    <li><a href="#stored-procedures">Stored Procedures</a></li>
    <li><a href="#resultados-de-optimización">Resultados de optimización</a></li>
    <li><a href="#índices-creados">Índices creados</a></li>
    <li><a href="#estructura-de-ramas-git">Estructura de ramas Git</a></li>
    <li><a href="#criterios-de-evaluación">Criterios de evaluación</a></li>
  </ol>
</details>

---

## Tecnologías utilizadas

- Microsoft SQL Server 2019+ (Developer / Express / Docker)
- SQL Server Management Studio (SSMS) 19+
- T-SQL — Window Functions, CTEs, Stored Procedures
- Git / GitHub

---

## Estructura del proyecto

```
optimizacion-bd-ecommerce/
├── docs/
│   ├── modelo-entidad-relacion.png       # Diagrama ER exportado
│   ├── diccionario-datos.md              # Descripción de tablas y columnas
│   └── optimizacion-resultados.md        # Reporte comparativo antes/después
├── sql/
│   ├── 01_schema.sql                     # DDL: base de datos y tablas
│   ├── 02_seed.sql                       # Datos masivos de prueba
│   ├── 03_consultas-lentas.sql           # consultas con problemas de rendimiento
│   ├── 04_indices.sql                    # Definición de índices de optimización
│   ├── 05_consultas-optimizadas.sql      # Consultas reescritas y optimizadas
│   └── 06_stored_procedures.sql          # stored procedures parametrizados
├── evidencias/
│   ├── plan-ejecucion-antes-1.png        #Captura de las métricas antes de la optimización
│   ├── plan-ejecucion-despues-1.png      #Captura métricas después de la optimización
│   ├── statistics-io-comparacion.png     #Captura de la compración de las métricas antes y después de la creación de los indices
│   └── stored-procedures-pruebas.png     #Captura de los resultados de los SPs
└── README.md
```

---

## Cómo ejecutar

### Prerrequisitos

- SQL Server 2019 o superior instalado
- SSMS 19+ o Azure Data Studio 1.40+
- ~500 MB de espacio en disco

### Pasos de ejecución

> **El orden es obligatorio.** Cada script depende del anterior.

```
1. Ejecutar sql/01_schema.sql  →  Creación de bd_ecommerce_alt con las 6 tablas
2. Ejecutar sql/02_seed.sql    →  Generación de datos 
3. Ejecutar sql/03_consultas-lentas.sql   →  Capturar métricas antes de la optimización
4. Ejecutar sql/04_indices.sql            →  Crear los índices
5. Ejecutar sql/05_consultas-optimizadas.sql  →  Capturar métricas después de la creación de los índices
6. Ejecutar sql/06_stored_procedures.sql  →  Crear y probar los SPs
```

### Capturar planes de ejecución

1. Abrir el script en SSMS
2. Activar **Include Actual Execution Plan** 
3. Ejecutar el script
4. Pestaña **Messages** → copiar tiempos CPU, elapsed y logical reads
5. Pestaña **Execution Plan** → clic derecho → *Save Execution Plan As…*
---

## Estructura de la base de datos

### Tablas

| Tabla | Descripción | Registros generados |
|---|---|---|
| `categorias` | Catálogo de categorías de productos | 20 |
| `productos` | Artículos disponibles para venta | 5 000 |
| `clientes` | Compradores registrados | 200 |
| `ordenes` | Cabecera de cada transacción | 5 000 |
| `detalle_orden` | Líneas de producto por orden | mayor a 17 000 |
| `pagos` | Transacciones de cobro | 5 000 |

### Limpiar y reiniciar datos

```sql
USE ecommerce_db;
GO
DELETE FROM pagos;
DELETE FROM detalle_orden;
DELETE FROM ordenes;
DELETE FROM clientes;
DELETE FROM productos;
DELETE FROM categorias;

DBCC CHECKIDENT ('pagos',         RESEED, 0);
DBCC CHECKIDENT ('detalle_orden', RESEED, 0);
DBCC CHECKIDENT ('ordenes',       RESEED, 0);
DBCC CHECKIDENT ('clientes',      RESEED, 0);
DBCC CHECKIDENT ('productos',     RESEED, 0);
DBCC CHECKIDENT ('categorias',    RESEED, 0);
```

---

## Stored Procedures

### `usp_buscar_productos`

Busca productos con filtros opcionales y devuelve resultados paginados.

| Parámetro | Tipo | Default | Descripción |
|---|---|---|---|
| `@categoria_id` | INT | NULL | Filtrar por categoría |
| `@precio_min` | DECIMAL(10,2) | NULL | Precio mínimo |
| `@precio_max` | DECIMAL(10,2) | NULL | Precio máximo |
| `@texto` | NVARCHAR(200) | NULL | Búsqueda en nombre/SKU |
| `@pagina` | INT | 1 | Número de página |
| `@tam_pagina` | INT | 20 | Registros por página |

```sql
-- Todos los productos activos (página 1, 20 por página)
EXEC usp_buscar_productos;

-- Filtrar por precio mínimo
EXEC usp_buscar_productos @precio_min = 200;

-- Búsqueda por texto/SKU
EXEC usp_buscar_productos @texto = 'SKU-0002';
```

---

### `usp_resumen_ventas_por_cliente`

Devuelve totales de ventas por cliente con ranking y segmentación RFM.

| Parámetro | Tipo | Default | Descripción |
|---|---|---|---|
| `@fecha_inicio` | DATETIME2 | Año anterior | Inicio del rango de fechas |
| `@fecha_fin` | DATETIME2 | Hoy | Fin del rango de fechas |
| `@ciudad` | NVARCHAR(100) | NULL | Filtrar por ciudad |
| `@top_n` | INT | NULL (todos) | Limitar a top N clientes |

```sql
-- Resumen del último año (defaults)
EXEC usp_resumen_ventas_por_cliente;

-- Filtrar por ciudad y top 10
EXEC usp_resumen_ventas_por_cliente
    @ciudad = 'CDMX',
    @top_n  = 10;

-- Top 5 clientes a nivel global
EXEC usp_resumen_ventas_por_cliente @top_n = 5;
```

---

### `usp_top_productos`

Devuelve los N productos más vendidos en un período con ranking por métrica.

| Parámetro | Tipo | Default | Descripción |
|---|---|---|---|
| `@top_n` | INT | 10 | Número de productos a retornar |
| `@fecha_inicio` | DATETIME2 | Inicio del año | Inicio del rango |
| `@fecha_fin` | DATETIME2 | Hoy | Fin del rango |
| `@categoria_id` | INT | NULL | Filtrar por categoría |
| `@metrica` | NVARCHAR(20) | 'monto' | `monto` \| `cantidad` \| `ordenes` |

```sql
-- Top 10 por monto (default)
EXEC usp_top_productos;

-- Top 5 por cantidad de unidades vendidas
EXEC usp_top_productos @top_n = 5, @metrica = 'cantidad';

-- Top 10 de una categoría específica por monto
EXEC usp_top_productos
    @top_n        = 10,
    @categoria_id = 1,
    @metrica      = 'monto';
```

---

## Resultados de optimización

### Resumen ejecutivo

| Métrica | Antes | Después | Mejora |
|---|---|---|---|
| CPU acumulado (ms) | 722 | 209 | **−71 %** |
| Elapsed acumulado (ms) | 3 639 | 1 400 | **−62 %** |
| Logical reads acumuladas | 1 970 631 | 81 885 | **−96 %** |
| Missing Indexes detectados | 4 | 0 | **−100 %** |

---

### Consulta #1 
| Métrica | Antes | Después | Δ |
|---|---|---|---|
| CPU (ms) | 93 | 31 | **−67 %** |
| Elapsed (ms) | 307 | 70 | **−77 %** |
| Logical reads productos | 17 535 | 3 532 | **−80 %** |
| Logical reads total | 17 535 | 3 532 | **−80 %** |
| Operación principal | Clustered Index Scan + Hash Match + Sort | Index Seek + Nested Loop | ✅ |

---

### Consulta #2 

| Métrica | Antes | Después | Δ |
|---|---|---|---|
| CPU (ms) | 133 | 31 | **−77 %** |
| Elapsed (ms) | 123 | 31 | **−75 %** |
| Logical reads ordenes | 4 013 | 1 296 | **−68 %** |
| Logical reads clientes | 86 | 64 | **−26 %** |
| Logical reads total | 4 819 | 1 947 | **−60 %** |
| Operación principal | Hash Match Semi Join + CI Scan | Index Seek + Semi Join | ✅ |

---

### Consulta #3

| Métrica | Antes | Después |
|---|---|---|---|
| CPU (ms) | 173 | 31 |
| Elapsed (ms) | 173 | 31 |
| Logical reads ordenes | 407 | 67 |
| Logical reads detalle_orden | 6 452 |
| Logical reads productos | 1 811 206 |
| Logical reads clientes | 8 200 | 210 600 |
| Logical reads categorias | 2 200 | 22 000 |
| Logical reads total | **1 925 665** | **67 007** |

---

### Consulta #4 

| Métrica | Antes | Después |
|---|---|---|---|
| CPU (ms) | 289 | 93 |
| Elapsed (ms) | 3 012 | 1 205 |
| Logical reads productos | 17 591 | 9 154 |
| Logical reads categorias | 22 | 22 |
| Logical reads total | 17 793 | 9 399 |


---

### Consulta #5 

| Métrica | Antes | Después |
|---|---|---|---|
| CPU (ms) | 34 | 23 |
| Elapsed (ms) | 24 | 24 |
| Logical reads ordenes | 4 013 | 1 296 |
| Logical reads clientes | 86 | 64 |
| Logical reads total | 4 819 | 1 947 |

---

## Índices creados

| Índice | Tabla | Tipo | Columnas clave | INCLUDE | WHERE |
|---|---|---|---|---|---|
| `IX_productos_fecha_creacion` | productos | NC Covering | fecha_creacion | sku, nombre, categoria_id, precio, stock, activo | — |
| `IX_productos_activos_precio` | productos | NC Filtered | precio, categoria_id | sku, nombre, stock | activo = 1 |
| `IX_productos_categoria_precio` | productos | NC Covering | categoria_id, precio | sku, nombre, stock, activo, fecha_creacion | — |
| `IX_ordenes_cliente_fecha` | ordenes | NC Covering | cliente_id, fecha | estado, subtotal, impuestos, total | — |
| `IX_ordenes_fecha_estado` | ordenes | NC Covering | fecha, estado | cliente_id, subtotal, impuestos, total | — |
| `IX_ordenes_entregadas` | ordenes | NC Filtered | cliente_id, fecha | total, estado | estado IN ('entregada','enviada') |
| `IX_detalle_orden_orden_id` | detalle_orden | NC Covering | orden_id | producto_id, cantidad, precio_unitario, subtotal | — |
| `IX_detalle_orden_producto_id` | detalle_orden | NC Covering | producto_id | orden_id, cantidad, subtotal | — |
| `IX_pagos_orden_id` | pagos | NC Covering | orden_id | metodo, monto, fecha, estado | — |
| `IX_pagos_completados_fecha` | pagos | NC Filtered | fecha, orden_id | metodo, monto | estado = 'completado' |
| `IX_clientes_ciudad_registro` | clientes | NC Covering | ciudad, fecha_registro | nombre, apellido, correo | — |

### Eliminar todos los índices (rollback)

```sql
DROP INDEX IF EXISTS IX_productos_fecha_creacion   ON productos;
DROP INDEX IF EXISTS IX_productos_activos_precio    ON productos;
DROP INDEX IF EXISTS IX_productos_categoria_precio  ON productos;
DROP INDEX IF EXISTS IX_ordenes_cliente_fecha       ON ordenes;
DROP INDEX IF EXISTS IX_ordenes_fecha_estado        ON ordenes;
DROP INDEX IF EXISTS IX_ordenes_entregadas          ON ordenes;
DROP INDEX IF EXISTS IX_detalle_orden_orden_id      ON detalle_orden;
DROP INDEX IF EXISTS IX_detalle_orden_producto_id   ON detalle_orden;
DROP INDEX IF EXISTS IX_pagos_orden_id              ON pagos;
DROP INDEX IF EXISTS IX_pagos_completados_fecha     ON pagos;
DROP INDEX IF EXISTS IX_clientes_ciudad_registro    ON clientes;
```

---


## Referencias

- [SQL Server Index Architecture](https://learn.microsoft.com/sql/relational-databases/indexes/indexes)
- [Filtered Indexes](https://learn.microsoft.com/sql/relational-databases/indexes/create-filtered-indexes)
- [SET STATISTICS IO](https://learn.microsoft.com/sql/t-sql/statements/set-statistics-io-transact-sql)
- [Window Functions](https://learn.microsoft.com/sql/t-sql/functions/ranking-functions-transact-sql)
- [Execution Plan Analysis](https://learn.microsoft.com/sql/relational-databases/performance/display-an-actual-execution-plan)

---

## Contacto

Link del Repositorio: [optimizacion-bd-ecommerce](https://github.com/joaquinzarates/optimizacion-bd-ecommerce)

<p align="right">(<a href="#readme-top">Regresar al Inicio</a>)</p>

<!-- MARKDOWN LINKS & BADGES -->
[sqlserver-shield]: https://img.shields.io/badge/SQL_Server-2019+-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white
[sqlserver-url]: https://www.microsoft.com/sql-server
[ssms-shield]: https://img.shields.io/badge/SSMS-19+-0078D4?style=for-the-badge&logo=microsoft&logoColor=white
[ssms-url]: https://learn.microsoft.com/sql/ssms/download-sql-server-management-studio-ssms
[license-shield]: https://img.shields.io/badge/License-MIT-green?style=for-the-badge
[license-url]: https://opensource.org/licenses/MIT
