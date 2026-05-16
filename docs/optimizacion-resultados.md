# Tablas comparativas ANTES vs DESPUÉS
**Consulta 1** 

| Métrica                  | Antes | Después |
|--------------------------|-------|---------|
| CPU (ms)                 | 93    | 31      |
| Elapsed (ms)             | 307   | 70      |
| Logical reads productos  | 17535 | 3532    |
| Logical reads total      | 17535 | 3532    |


**CONSULTA 2**

| Métrica                  | Antes | Después |
|--------------------------|-------|---------|
| CPU (ms)                 | 133   | 31      |
| Elapsed (ms)             | 123   | 31      |
| Logical reads ordenes    | 4013  | 1296    |
| Logical reads clientes   | 86    | 64      |
| Logical reads total      | 4819  | 1947    |

**CONSULTA 3**

| Métrica                       | Antes   | Después |
|-------------------------------|---------|---------|
| CPU (ms)                      | 173     | 31      |
| Elapsed (ms)                  | 173     | 31      |
| Logical reads ordenes         | 407     | 67      |
| Logical reads detalle_orden   | 6452    | 5222    |
| Logical reads productos       | 1811206 | 200077  |
| Logical reads clientes        | 8200    | 210600  |
| Logical reads categorias      | 2200    | 22000   |
| Logical reads total           | 1925665 | 67007   |

**CONSULTA 4**

| Métrica                  | Antes | Después |
|--------------------------|-------|---------|
| CPU (ms)                 | 289   | 93      |
| Elapsed (ms)             | 3012  | 1205    |
| Logical reads productos  | 17591 | 9154    |
| Logical reads categorias | 22    | 22      |
| Logical reads total      | 17793 | 9399    |

**CONSULTA 5**

| Métrica                  | Antes | Después |
|--------------------------|-------|---------|
| CPU (ms)                 | 34    | 23      |
| Elapsed (ms)             | 24    | 24      |
| Logical reads ordenes    | 4013  | 1296    |
| Logical reads clientes   | 86    | 64      |
| Logical reads total      | 4819  | 1947    |