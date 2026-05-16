USE bd_ecommerce_alt;
GO


USE ecommerce_db;
GO

CREATE OR ALTER PROCEDURE usp_buscar_productos
    @categoria_id  INT            = NULL,
    @precio_min    DECIMAL(10,2)  = NULL,
    @precio_max    DECIMAL(10,2)  = NULL,
    @texto         NVARCHAR(200)  = NULL,
    @pagina        INT            = 1,      -- 1-based
    @tam_pagina    INT            = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @pagina      IS NULL OR @pagina     < 1  SET @pagina     = 1;
    IF @tam_pagina  IS NULL OR @tam_pagina < 1  SET @tam_pagina = 20;
    IF @tam_pagina > 100                        SET @tam_pagina = 100;

    DECLARE @offset INT = (@pagina - 1) * @tam_pagina;

    DECLARE @like NVARCHAR(202) = NULL;
    IF @texto IS NOT NULL AND LEN(LTRIM(RTRIM(@texto))) > 0
        SET @like = N'%' + LTRIM(RTRIM(@texto)) + N'%';

    SELECT COUNT_BIG(*) AS total_registros
    FROM productos p
    WHERE p.activo = 1
      AND (@categoria_id IS NULL OR p.categoria_id = @categoria_id)
      AND (@precio_min   IS NULL OR p.precio       >= @precio_min)
      AND (@precio_max   IS NULL OR p.precio       <= @precio_max)
      AND (@like         IS NULL OR p.nombre       LIKE @like
                                 OR p.sku          LIKE @like);

    SELECT
        p.id,
        p.sku,
        p.nombre,
        p.descripcion,
        cat.nombre      AS categoria,
        p.precio,
        p.stock,
        p.fecha_creacion,
        ROW_NUMBER() OVER (ORDER BY p.precio ASC, p.id ASC) AS nro_fila,
        RANK()       OVER (PARTITION BY p.categoria_id
                           ORDER BY p.precio ASC)           AS rank_precio_cat
    FROM productos p
        JOIN categorias cat ON cat.id = p.categoria_id
    WHERE p.activo = 1
      AND (@categoria_id IS NULL OR p.categoria_id = @categoria_id)
      AND (@precio_min   IS NULL OR p.precio       >= @precio_min)
      AND (@precio_max   IS NULL OR p.precio       <= @precio_max)
      AND (@like         IS NULL OR p.nombre       LIKE @like
                                 OR p.sku          LIKE @like)
    ORDER BY p.precio ASC, p.id ASC
    OFFSET @offset ROWS FETCH NEXT @tam_pagina ROWS ONLY;
END;
GO


CREATE OR ALTER PROCEDURE usp_resumen_ventas_por_cliente
    @fecha_inicio  DATETIME2 = NULL,
    @fecha_fin     DATETIME2 = NULL,
    @ciudad        NVARCHAR(100) = NULL,
    @top_n         INT           = NULL    
AS
BEGIN
    SET NOCOUNT ON;

    IF @fecha_inicio IS NULL
        SET @fecha_inicio = DATEFROMPARTS(YEAR(SYSUTCDATETIME()) - 1, 1, 1);
    IF @fecha_fin IS NULL
        SET @fecha_fin = SYSUTCDATETIME();
    IF @top_n IS NULL OR @top_n < 1
        SET @top_n = 2147483647;   -- Sin límite efectivo

    ;WITH ventas_cliente AS (
        SELECT
            c.id            AS cliente_id,
            c.nombre,
            c.apellido,
            c.ciudad,
            c.correo,
            c.fecha_registro,
            COUNT(o.id)             AS total_ordenes,
            SUM(o.total)            AS monto_total,
            SUM(o.subtotal)         AS subtotal_neto,
            SUM(o.impuestos)        AS impuestos_pagados,
            AVG(o.total)            AS ticket_promedio,
            MIN(o.fecha)            AS primera_compra,
            MAX(o.fecha)            AS ultima_compra,
            DATEDIFF(DAY, MAX(o.fecha), SYSUTCDATETIME()) AS dias_sin_compra
        FROM clientes c
            JOIN ordenes o ON o.cliente_id = c.id
        WHERE o.fecha  >= @fecha_inicio
          AND o.fecha  <  DATEADD(DAY, 1, @fecha_fin)
          AND o.estado IN ('entregada', 'enviada', 'confirmada')
          AND (@ciudad IS NULL OR c.ciudad = @ciudad)
        GROUP BY c.id, c.nombre, c.apellido, c.ciudad, c.correo, c.fecha_registro
    ),
    ranking_clientes AS (
        SELECT
            *,
            ROW_NUMBER() OVER (ORDER BY monto_total DESC)            AS posicion_global,
            RANK()       OVER (ORDER BY monto_total DESC)            AS rank_ventas,
            RANK()       OVER (PARTITION BY ciudad
                               ORDER BY monto_total DESC)            AS rank_ciudad,
            NTILE(4)     OVER (ORDER BY monto_total DESC)            AS cuartil
        FROM ventas_cliente
    )
    SELECT TOP (@top_n)
        posicion_global,
        rank_ventas,
        rank_ciudad,
        cuartil,
        cliente_id,
        nombre + N' ' + apellido    AS cliente_completo,
        ciudad,
        correo,
        fecha_registro,
        total_ordenes,
        monto_total,
        subtotal_neto,
        impuestos_pagados,
        ticket_promedio,
        primera_compra,
        ultima_compra,
        dias_sin_compra,
        CASE
            WHEN cuartil = 1 AND dias_sin_compra <= 30  THEN N'VIP Activo'
            WHEN cuartil = 1                            THEN N'VIP Inactivo'
            WHEN cuartil = 2 AND dias_sin_compra <= 60  THEN N'Frecuente'
            WHEN cuartil = 3                            THEN N'Ocasional'
            ELSE                                             N'En Riesgo'
        END AS segmento_cliente
    FROM ranking_clientes
    ORDER BY posicion_global;
END;
GO