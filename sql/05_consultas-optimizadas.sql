USE bd_ecommerce_alt;
GO

SET STATISTICS IO  ON;
SET STATISTICS TIME ON;
GO


PRINT 'CONSULTA OPTIMIZADA 1';

DECLARE @inicio_anio DATETIME2 = DATEFROMPARTS(YEAR(GETDATE()) - 1, 1,  1);
DECLARE @fin_anio    DATETIME2 = DATEFROMPARTS(YEAR(GETDATE()),     1,  1);

SELECT
    p.id,
    p.sku,
    p.nombre,
    p.categoria_id,
    p.precio,
    p.stock,
    p.fecha_creacion
FROM productos p
WHERE p.fecha_creacion >= @inicio_anio
  AND p.fecha_creacion <  @fin_anio
  AND p.activo = 1;
GO


PRINT 'CONSULTA OPTIMIZADA 2 ';

SELECT
    c.id,
    c.nombre,
    c.apellido,
    c.correo,
    c.ciudad
FROM clientes c
WHERE EXISTS (
    SELECT 1
    FROM ordenes o
    WHERE o.cliente_id = c.id
      AND o.estado     = 'entregada'
);
GO


PRINT 'CONSULTA OPTIMIZADA 3';

DECLARE @fecha_desde DATETIME2 = DATEADD(MONTH, -1, SYSUTCDATETIME());

SELECT
    o.id            AS orden_id,
    c.nombre + N' ' + c.apellido AS cliente,
    c.ciudad,
    p.nombre        AS producto,
    p.sku,
    cat.nombre      AS categoria,
    do.cantidad,
    do.precio_unitario,
    do.subtotal,
    o.fecha,
    o.estado,
    o.total
FROM ordenes o
    JOIN clientes      c   ON c.id          = o.cliente_id
    JOIN detalle_orden do  ON do.orden_id   = o.id
    JOIN productos     p   ON p.id          = do.producto_id
    JOIN categorias    cat ON cat.id        = p.categoria_id
WHERE o.fecha >= @fecha_desde
ORDER BY o.total DESC
OFFSET 0 ROWS FETCH NEXT 100 ROWS ONLY;
GO


PRINT 'CONSULTA OPTIMIZADA 4';

DECLARE @texto       NVARCHAR(200) = N'Modelo';
DECLARE @precio_min  DECIMAL(10,2) = 500.00;
DECLARE @precio_max  DECIMAL(10,2) = 5000.00;

SELECT
    p.id,
    p.sku,
    p.nombre,
    p.precio,
    p.stock,
    c.nombre AS categoria
FROM productos p
    JOIN categorias c ON c.id = p.categoria_id
WHERE p.activo  = 1
  AND p.precio  BETWEEN @precio_min AND @precio_max   -- filtro sargable primero
  AND p.nombre  LIKE N'%' + @texto + N'%';            -- LIKE al final, menos filas
GO



PRINT 'CONSULTA OPTIMIZADA 5';

DECLARE @fecha_ini DATETIME2 = '2024-01-01';
DECLARE @fecha_fin DATETIME2 = '2025-12-31';

SELECT
    c.id,
    c.nombre,
    c.apellido,
    c.ciudad,
    COUNT(o.id)             AS total_ordenes,
    SUM(o.total)            AS monto_total,
    AVG(o.total)            AS ticket_promedio,
    MAX(o.fecha)            AS ultima_compra,
    RANK() OVER (ORDER BY SUM(o.total) DESC)       AS ranking_global,
    RANK() OVER (PARTITION BY c.ciudad
                 ORDER BY SUM(o.total) DESC)        AS ranking_ciudad
FROM clientes c
    JOIN ordenes o ON o.cliente_id = c.id
WHERE o.fecha  >= @fecha_ini
  AND o.fecha  <  DATEADD(DAY, 1, @fecha_fin)      
  AND o.estado IN ('entregada', 'enviada')          
GROUP BY c.id, c.nombre, c.apellido, c.ciudad
ORDER BY monto_total DESC;
GO

SET STATISTICS IO  OFF;
SET STATISTICS TIME OFF;
GO
