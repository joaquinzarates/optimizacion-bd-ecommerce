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
