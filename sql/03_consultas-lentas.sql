use bd_ecommerce;
GO

SET STATISTICS IO  ON;
SET STATISTICS TIME ON;
GO



SELECT *
FROM productos
WHERE YEAR(fecha_creacion) = YEAR(GETDATE()) - 1
  AND activo = 1;
GO


SET STATISTICS IO  ON;
SET STATISTICS TIME ON;
GO
PRINT 'CONSULTA LENTA 1';

SELECT *
FROM productos
WHERE YEAR(fecha_creacion) = YEAR(GETDATE()) - 1
  AND activo = 1;
GO

PRINT 'CONSULTA LENTA 2';


SELECT c.id,
       c.nombre,
       c.apellido,
       c.correo,
       c.ciudad
FROM clientes c
WHERE (
    SELECT COUNT(*)
    FROM ordenes o
    WHERE o.cliente_id = c.id
      AND o.estado = 'entregada'
) > 0;
GO

PRINT 'CONSULTA LENTA 3';


SELECT
    o.id            AS orden_id,
    c.nombre + ' ' + c.apellido AS cliente,
    c.ciudad,
    p.nombre        AS producto,
    p.sku,
    cat.nombre      AS categoria,
    do.cantidad,
    do.precio_unitario,
    do.subtotal,
    o.fecha,
    o.estado
FROM ordenes o
    JOIN clientes     c   ON c.id   = o.cliente_id
    JOIN detalle_orden do ON do.orden_id  = o.id
    JOIN productos    p   ON p.id   = do.producto_id
    JOIN categorias   cat ON cat.id = p.categoria_id
WHERE o.fecha >= DATEADD(MONTH, -1, GETDATE())
ORDER BY o.total DESC;
GO

PRINT 'CONSULTA LENTA 4';

SELECT
    p.id,
    p.sku,
    p.nombre,
    p.precio,
    p.stock,
    c.nombre AS categoria
FROM productos p
    JOIN categorias c ON c.id = p.categoria_id
WHERE p.nombre LIKE '%Modelo%'
  AND p.precio BETWEEN 500 AND 5000
  AND p.activo = 1;
GO

PRINT 'CONSULTA LENTA 5';

SELECT
    c.id,
    c.nombre,
    c.apellido,
    c.ciudad,
    COUNT(o.id)         AS total_ordenes,
    SUM(o.total)        AS monto_total,
    AVG(o.total)        AS ticket_promedio,
    MAX(o.fecha)        AS ultima_compra
FROM clientes c
    JOIN ordenes o ON o.cliente_id = c.id
WHERE o.fecha  BETWEEN '2024-01-01' AND '2025-12-31'
  AND o.estado IN ('entregada', 'enviada')
GROUP BY c.id, c.nombre, c.apellido, c.ciudad
ORDER BY monto_total DESC;
GO


SET STATISTICS IO  OFF;
SET STATISTICS TIME OFF;
GO
