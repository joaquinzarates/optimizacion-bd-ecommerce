USE bd_ecommerce_alt
GO
 
SET NOCOUNT ON;

INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónica',          'Dispositivos electrónicos y accesorios tecnológicos'),
('Computación',          'Laptops, equipos de escritorio, periféricos y componentes'),
('Telefonía',            'Smartphones, tablets y accesorios móviles'),
('Televisores',          'Pantallas inteligentes y monitores '),
('Audio',                'Audífonos, bocinas y equipos de sonido'),
('Fotografía',           'Cámaras, lentes y accesorios fotográficos'),
('Videojuegos',          'Consolas, juegos y accesorios para gaming'),
('Electrodomésticos',    'Línea blanca y aparatos para el hogar'),
('Hogar y Muebles',      'Muebles, decoración y artículos para el hogar'),
('Ropa Caballero',          'Ropa, calzado y accesorios para caballero'),
('Ropa Dama',           'Ropa, calzado y accesorios para dama'),
('Ropa Infantil',           'Ropa, calzado y juguetes para niños'),
('Deportes',             'Artículos deportivos y ropa fitness'),
('Libros',               'Libros físicos de distintos géneros'),
('Juguetes',             'Juguetes y juegos de mesa'),
('Belleza',              'Cosméticos, perfumes y cuidado personal'),
('Salud',                'Suplementos, vitaminas y medicamentos'),
('Automotriz',           'Accesorios y partes para automóviles'),
('Herramientas',         'Herramientas manuales y eléctricas'),
('Mascotas',             'Alimento y accesorios para el cuidado para mascotas');
GO




SELECT * FROM productos;
GO


DECLARE @cat   INT;
DECLARE @i     INT = 1;
DECLARE @catId INT;
DECLARE @sku   NVARCHAR(50);
DECLARE @nombre NVARCHAR(200);
DECLARE @precio DECIMAL(10,2);
DECLARE @stock  INT;
 
DECLARE @cat_names TABLE (id INT, nombre NVARCHAR(100));
INSERT INTO @cat_names
SELECT id, nombre FROM categorias;
 
WHILE @i <= 5000
BEGIN
    SET @catId  = ((@i - 1) % 20) + 1;
    SET @sku    = N'SKU-' + RIGHT('0000' + CAST(@i AS NVARCHAR), 4);
    SET @precio = CAST((RAND(CHECKSUM(NEWID())) * 9900 + 100) AS DECIMAL(10,2));
    SET @stock  = CAST(RAND(CHECKSUM(NEWID())) * 500 AS INT);
 
    SET @nombre = (SELECT TOP 1 nombre FROM @cat_names WHERE id = @catId)
                  + N' Modelo-' + CAST(@i AS NVARCHAR);
 
    INSERT INTO productos (sku, nombre, descripcion, categoria_id, precio, stock, activo, fecha_creacion)
    VALUES (
        @sku,
        @nombre,
        N'Descripción detallada del producto: ' + @nombre + N', de calidad garantizada.',
        @catId,
        @precio,
        @stock,
        CASE WHEN RAND(CHECKSUM(NEWID())) > 0.1 THEN 1 ELSE 0 END,   -- 90 % activos
        DATEADD(DAY, -CAST(RAND(CHECKSUM(NEWID())) * 730 AS INT), SYSUTCDATETIME())
    );
 
    SET @i += 1;
END
GO
 
SELECT * FROM productos;
GO
 







SELECT * FROM clientes;
GO


DECLARE @nombres  NVARCHAR(MAX) = N'Carlos,María,José,Ana,Luis,Laura,Miguel,Sofía,Jorge,Elena,Pedro,Carmen,Andrés,Lucía,Roberto,Isabel,Francisco,Diana,Alejandro,Valentina';
DECLARE @apellidos NVARCHAR(MAX) = N'García,Rodríguez,Martínez,López,González,Pérez,Sánchez,Ramírez,Torres,Flores,Rivera,Gómez,Díaz,Morales,Reyes,Cruz,Hernández,Jiménez,Ruiz,Vargas';
DECLARE @ciudades  NVARCHAR(MAX) = N'CDMX,Guadalajara,Monterrey,Puebla,Tijuana,León,Juárez,Zapopan,Mérida,Querétaro,San Luis Potosí,Mexicali,Aguascalientes,Hermosillo,Chihuahua';
 
DECLARE @n_arr  TABLE (idx INT IDENTITY, val NVARCHAR(100));
DECLARE @a_arr  TABLE (idx INT IDENTITY, val NVARCHAR(100));
DECLARE @c_arr  TABLE (idx INT IDENTITY, val NVARCHAR(100));
 

INSERT INTO @n_arr (val) SELECT value FROM STRING_SPLIT(@nombres,   ',');
INSERT INTO @a_arr (val) SELECT value FROM STRING_SPLIT(@apellidos, ',');
INSERT INTO @c_arr (val) SELECT value FROM STRING_SPLIT(@ciudades,  ',');
 
DECLARE @nc INT = (SELECT COUNT(*) FROM @n_arr);
DECLARE @ac INT = (SELECT COUNT(*) FROM @a_arr);
DECLARE @cc INT = (SELECT COUNT(*) FROM @c_arr);
 
DECLARE @ci INT = 1;
WHILE @ci <= 200
BEGIN
    DECLARE @nom  NVARCHAR(100) = (SELECT val FROM @n_arr  WHERE idx = ((@ci - 1) % @nc) + 1);
    DECLARE @ape  NVARCHAR(100) = (SELECT val FROM @a_arr  WHERE idx = ((@ci - 1) % @ac) + 1);
    DECLARE @ciu  NVARCHAR(100) = (SELECT val FROM @c_arr  WHERE idx = ((@ci - 1) % @cc) + 1);
    DECLARE @correo NVARCHAR(200) = LOWER(@nom) + '.' + LOWER(@ape) + CAST(@ci AS NVARCHAR) + N'@correo.com';
    DECLARE @tel  NVARCHAR(20) = N'+52 55 ' + RIGHT('0000' + CAST(CAST(RAND(CHECKSUM(NEWID()))*9999 AS INT) AS NVARCHAR),4)
                                            + N' ' + RIGHT('0000' + CAST(CAST(RAND(CHECKSUM(NEWID()))*9999 AS INT) AS NVARCHAR),4);
 
    INSERT INTO clientes (nombre, apellido, correo, telefono, fecha_registro, ciudad)
    VALUES (
        @nom, @ape, @correo, @tel,
        DATEADD(DAY, -CAST(RAND(CHECKSUM(NEWID())) * 1095 AS INT), SYSUTCDATETIME()),
        @ciu
    );
 
    SET @ci += 1;
END
GO
 
SELECT * FROM clientes;
GO




SELECT * FROM ordenes;
GO
SELECT * FROM detalle_orden;
GO


SET NOCOUNT ON;

DECLARE @oi        INT = 1;
DECLARE @cli_count INT = (SELECT COUNT(*) FROM clientes);
DECLARE @pro_count INT = (SELECT COUNT(*) FROM productos);
DECLARE @ord_id    INT;
DECLARE @est_val   NVARCHAR(30);
DECLARE @cli_id    INT;
DECLARE @fec_ord   DATETIME2;
DECLARE @lineas    INT;
DECLARE @li        INT;
DECLARE @prod_id   INT;
DECLARE @qty       INT;
DECLARE @p_unit    DECIMAL(10,2);
DECLARE @lin_sub   DECIMAL(12,2);
DECLARE @sub_total DECIMAL(12,2);
DECLARE @imp       DECIMAL(12,2);
DECLARE @tot       DECIMAL(12,2);

CREATE TABLE #estados (idx INT PRIMARY KEY, val NVARCHAR(30) NOT NULL);
INSERT INTO #estados VALUES (1,'pendiente'),(2,'confirmada'),(3,'procesando'),
                             (4,'enviada'),(5,'entregada'),(6,'cancelada');


CREATE TABLE #prods (rn INT PRIMARY KEY IDENTITY(1,1), id INT NOT NULL, precio DECIMAL(10,2) NOT NULL);
INSERT INTO #prods (id, precio) SELECT id, precio FROM productos ORDER BY id;
DECLARE @pro_real INT = (SELECT COUNT(*) FROM #prods);

WHILE @oi <= 5000
BEGIN
    SET @cli_id  = (ABS(CHECKSUM(NEWID())) % @cli_count) + 1;
    SET @est_val = (SELECT val FROM #estados WHERE idx = (ABS(CHECKSUM(NEWID())) % 6) + 1);
    SET @fec_ord = DATEADD(MINUTE, -(ABS(CHECKSUM(NEWID())) % 525600), SYSUTCDATETIME());

    INSERT INTO ordenes (cliente_id, fecha, estado, subtotal, impuestos, total)
    VALUES (@cli_id, @fec_ord, @est_val, 0, 0, 0);

    SET @ord_id    = SCOPE_IDENTITY();
    SET @lineas    = (ABS(CHECKSUM(NEWID())) % 4) + 2;
    SET @li        = 1;
    SET @sub_total = 0;

    WHILE @li <= @lineas
    BEGIN
        SELECT @prod_id = id, @p_unit = precio
        FROM #prods
        WHERE rn = (ABS(CHECKSUM(NEWID())) % @pro_real) + 1;

        SET @qty     = (ABS(CHECKSUM(NEWID())) % 9) + 1;
        SET @lin_sub = @qty * @p_unit;

        INSERT INTO detalle_orden (orden_id, producto_id, cantidad, precio_unitario, subtotal)
        VALUES (@ord_id, @prod_id, @qty, @p_unit, @lin_sub);

        SET @sub_total += @lin_sub;
        SET @li += 1;
    END

    SET @imp = ROUND(@sub_total * 0.16, 2);
    SET @tot = @sub_total + @imp;

    UPDATE ordenes SET subtotal = @sub_total, impuestos = @imp, total = @tot
    WHERE id = @ord_id;

    SET @oi += 1;
END

DROP TABLE #estados;
DROP TABLE #prods;
GO

 





INSERT INTO pagos (orden_id, metodo, monto, fecha, estado)
SELECT
    o.id,
    CASE (o.id % 5)
        WHEN 0 THEN 'TDC'
        WHEN 1 THEN 'TDD'
        WHEN 2 THEN 'paypal'
        WHEN 3 THEN 'transferencia'
        WHEN 4 THEN 'efectivo'
    END,
    o.total,
    DATEADD(MINUTE, ABS(CHECKSUM(NEWID())) % 1440, o.fecha),
    CASE (ABS(CHECKSUM(o.id * 7 + 13)) % 6)
        WHEN 0 THEN 'completado'
        WHEN 1 THEN 'completado'
        WHEN 2 THEN 'completado'
        WHEN 3 THEN 'fallido'
        WHEN 4 THEN 'pendiente'
        WHEN 5 THEN 'procesando'
    END
FROM (SELECT TOP 5000 id, total, fecha FROM ordenes ORDER BY id) o;
GO

select * from pagos;