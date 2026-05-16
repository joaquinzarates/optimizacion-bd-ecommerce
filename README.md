<a id="readme-top"></a>

[![SQL Server][sqlserver-shield]][sqlserver-url]
[![SSMS][ssms-shield]][ssms-url]
[![License][license-shield]][license-url]

# Optimización de Base de Datos — E-Commerce

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
- Azure Data Studio 1.40+ *(alternativa)*
- T-SQL — Window Functions, CTEs, Stored Procedures
- Git / GitHub

---

## Estructura del repositorio

```
optimizacion-bd-ecommerce/
├── docs/
│   ├── modelo-entidad-relacion.png       # Diagrama ER exportado
│   ├── diccionario-datos.md              # Descripción de tablas y columnas
│   └── optimizacion-resultados.md        # Reporte comparativo antes/después
├── sql/
│   ├── 01_schema.sql                     # DDL: base de datos y tablas
│   ├── 02_seed.sql                       # Datos masivos de prueba
│   ├── 03_consultas-lentas.sql           # 5 consultas con problemas de rendimiento
│   ├── 04_indices.sql                    # Definición de índices de optimización
│   ├── 05_consultas-optimizadas.sql      # Consultas reescritas y optimizadas
│   └── 06_stored_procedures.sql          # 3 stored procedures parametrizados
├── evidencias/
│   ├── plan-ejecucion-antes-1.png
│   ├── plan-ejecucion-antes-2.png
│   ├── plan-ejecucion-antes-3.png
│   ├── plan-ejecucion-antes-4.png
│   ├── plan-ejecucion-antes-5.png
│   ├── plan-ejecucion-despues-1.png
│   ├── plan-ejecucion-despues-2.png
│   ├── plan-ejecucion-despues-3.png
│   ├── plan-ejecucion-despues-4.png
│   ├── plan-ejecucion-despues-5.png
│   ├── statistics-io-antes.png
│   ├── statistics-io-despues.png
│   └── stored-procedures-pruebas.png
└── README.md
```

---

## Cómo ejecutar

### Prerrequisitos

- SQL Server 2019 o superior instalado
- SSMS 19+ o Azure Data Studio 1.40+
- ~500 MB de espacio en disco

### Opción Docker (sin instalación local)

```bash
docker run -e "ACCEPT_EULA=Y" \
           -e "SA_PASSWORD=TuPassword123!" \
           -p 1433:1433 \
           --name sqlserver \
           -d mcr.microsoft.com/mssql/server:2019-latest
```

Conexión: `localhost,1433` · Usuario: `sa` · Contraseña: `TuPassword123!`

### Pasos de ejecución

> **El orden es obligatorio.** Cada script depende del anterior.

```
1. Ejecutar sql/01_schema.sql  →  Crea ecommerce_db con las 6 tablas
2. Ejecutar sql/02_seed.sql    →  Genera datos masivos (~3–8 min)
3. Ejecutar sql/03_consultas-lentas.sql   →  Capturar métricas ANTES (Ctrl+M)
4. Ejecutar sql/04_indices.sql            →  Crear los 11 índices
5. Ejecutar sql/05_consultas-optimizadas.sql  →  Capturar métricas DESPUÉS
6. Ejecutar sql/06_stored_procedures.sql  →  Crear y probar los 3 SPs
```

### Capturar planes de ejecución

1. Abrir el script en SSMS
2. Activar **Include Actual Execution Plan** con `Ctrl+M`
3. Ejecutar el script
4. Pestaña **Messages** → copiar tiempos CPU, elapsed y logical reads
5. Pestaña **Execution Plan** → clic derecho → *Save Execution Plan As…*
6. Guardar en `evidencias/` con el nombre correspondiente

---

## Estructura de la base de datos

### Tablas

| Tabla | Descripción | Registros generados |
|---|---|---|
| `categorias` | Catálogo de categorías de productos | 20 |
| `productos` | Artículos disponibles para venta | 5 000 |
| `clientes` | Compradores registrados | 200 |
| `ordenes` | Cabecera de cada transacción | 5 000 |
| `detalle_orden` | Líneas de producto por orden | ~17 000 |
| `pagos` | Transacciones de cobro | 5 000 |

### Diagrama de relaciones

```
categorias (1) ──< productos (N)
                        │
                        └──< detalle_orden >──┐
                                               │
clientes (1) ──< ordenes (1) ──────────────────┘
                    │
                    └──< pagos
```

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

### Consulta #1 — JOIN sin índice en FK + filtro fecha + ORDER BY

| Métrica | Antes | Después | Δ |
|---|---|---|---|
| CPU (ms) | 93 | 31 | **−67 %** |
| Elapsed (ms) | 307 | 70 | **−77 %** |
| Logical reads productos | 17 535 | 3 532 | **−80 %** |
| Logical reads total | 17 535 | 3 532 | **−80 %** |
| Operación principal | Clustered Index Scan + Hash Match + Sort | Index Seek + Nested Loop | ✅ |

---

### Consulta #2 — Subconsulta correlacionada → EXISTS

| Métrica | Antes | Después | Δ |
|---|---|---|---|
| CPU (ms) | 133 | 31 | **−77 %** |
| Elapsed (ms) | 123 | 31 | **−75 %** |
| Logical reads ordenes | 4 013 | 1 296 | **−68 %** |
| Logical reads clientes | 86 | 64 | **−26 %** |
| Logical reads total | 4 819 | 1 947 | **−60 %** |
| Operación principal | Hash Match Semi Join + CI Scan | Index Seek + Semi Join | ✅ |

---

### Consulta #3 — Múltiples JOINs sin índices en clave foránea

| Métrica | Antes | Después | Δ |
|---|---|---|---|
| CPU (ms) | 173 | 31 | **−82 %** |
| Elapsed (ms) | 173 | 31 | **−82 %** |
| Logical reads ordenes | 407 | 67 | **−84 %** |
| Logical reads detalle_orden | 6 452 | 5 222 | **−19 %** |
| Logical reads productos | 1 811 206 | 200 077 | **−89 %** |
| Logical reads clientes | 8 200 | 210 600 | ⚠️ ver nota |
| Logical reads categorias | 2 200 | 22 000 | ⚠️ ver nota |
| Logical reads total | **1 925 665** | **67 007** | **−96 %** |
| Operación principal | 4× Hash Match + Sort | Nested Loop + Index Seek | ✅ |

> **Nota:** El incremento en clientes y categorías es consecuencia del cambio
> de Hash Match a Nested Loop. En lugar de un scan completo por tabla, el
> optimizador realiza seeks puntuales por cada fila coincidente. El resultado
> neto es una reducción del **96 %** en lecturas totales.

---

### Consulta #4 — LIKE con comodín inicial

| Métrica | Antes | Después | Δ |
|---|---|---|---|
| CPU (ms) | 289 | 93 | **−68 %** |
| Elapsed (ms) | 3 012 | 1 205 | **−60 %** |
| Logical reads productos | 17 591 | 9 154 | **−48 %** |
| Logical reads categorias | 22 | 22 | Sin cambio |
| Logical reads total | 17 793 | 9 399 | **−47 %** |
| Operación principal | Clustered Index Scan + Hash Match | Filtered Index Scan + LIKE | ✅ |

---

### Consulta #5 — Agregación GROUP BY + ORDER BY sin índices

| Métrica | Antes | Después | Δ |
|---|---|---|---|
| CPU (ms) | 34 | 23 | **−32 %** |
| Elapsed (ms) | 24 | 24 | Similar |
| Logical reads ordenes | 4 013 | 1 296 | **−68 %** |
| Logical reads clientes | 86 | 64 | **−26 %** |
| Logical reads total | 4 819 | 1 947 | **−60 %** |
| Operación principal | CI Scan + 2× Sort + Merge Join | Index Seek + Stream Aggregate | ✅ |

> **Nota:** Los tiempos elapsed son similares porque el volumen de datos es
> pequeño. La mejora real está en las lecturas lógicas (−60 %) y en el cambio
> de operador: de 2 Sort operators a Stream Aggregate, lo que escala
> favorablemente con millones de registros en producción.

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

## Estructura de ramas Git

```
main          ← versión estable y documentada
└── wip       ← rama de desarrollo activa
```

### Mensajes de commit

```bash
git commit -m "init: project structure with docs, sql and evidencias folders"
git commit -m "feat: add ecommerce_db schema with 6 tables and integrity constraints"
git commit -m "feat: add seed script generating 200 clients, 5000 products and 17000 details"
git commit -m "perf: add 5 slow queries with execution plan baseline and IO statistics"
git commit -m "perf: add 11 optimized indexes — non-clustered, covering and filtered"
git commit -m "perf: rewrite 5 slow queries with sargable predicates and explicit columns"
git commit -m "feat: add 3 parameterized SPs with window functions and OFFSET/FETCH pagination"
git commit -m "docs: add comparative optimization report with before/after real metrics"
```

---

## Criterios de evaluación

| Criterio | Puntos | Archivos |
|---|---|---|
| Modelado y carga masiva | 15 | `01_schema.sql`, `02_seed.sql`, `docs/diccionario-datos.md` |
| Análisis previo y planes | 20 | `03_consultas-lentas.sql`, `evidencias/plan-ejecucion-antes-*.png` |
| Índices y reescritura | 25 | `04_indices.sql`, `05_consultas-optimizadas.sql` |
| Stored Procedures | 15 | `06_stored_procedures.sql` |
| Reporte comparativo | 10 | `docs/optimizacion-resultados.md` |
| Documentación | 5 | `README.md`, `docs/` |
| GitHub + ramas + commits | 10 | Repositorio público, rama `wip`, ≥ 8 commits descriptivos |

---

## Referencias

- [SQL Server Index Architecture](https://learn.microsoft.com/sql/relational-databases/indexes/indexes)
- [Filtered Indexes](https://learn.microsoft.com/sql/relational-databases/indexes/create-filtered-indexes)
- [SET STATISTICS IO](https://learn.microsoft.com/sql/t-sql/statements/set-statistics-io-transact-sql)
- [Window Functions](https://learn.microsoft.com/sql/t-sql/functions/ranking-functions-transact-sql)
- [Execution Plan Analysis](https://learn.microsoft.com/sql/relational-databases/performance/display-an-actual-execution-plan)

---

## Contacto

Link del Repositorio: [optimizacion-bd-ecommerce](https://github.com/TU_USUARIO/optimizacion-bd-ecommerce)

<p align="right">(<a href="#readme-top">Regresar al Inicio</a>)</p>

<!-- MARKDOWN LINKS & BADGES -->
[sqlserver-shield]: https://img.shields.io/badge/SQL_Server-2019+-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white
[sqlserver-url]: https://www.microsoft.com/sql-server
[ssms-shield]: https://img.shields.io/badge/SSMS-19+-0078D4?style=for-the-badge&logo=microsoft&logoColor=white
[ssms-url]: https://learn.microsoft.com/sql/ssms/download-sql-server-management-studio-ssms
[license-shield]: https://img.shields.io/badge/License-MIT-green?style=for-the-badge
[license-url]: https://opensource.org/licenses/MIT
