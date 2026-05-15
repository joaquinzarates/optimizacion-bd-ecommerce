USE bd_ecommerce
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
 
WHILE @i <= 600
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


DECLARE @nombres  NVARCHAR(MAX) = N'Carlos,María,José,Ana,Luis,Laura,Miguel,Sofía,Jorge,Elena,Pedro,Carmen,Andrés,Lucía,Roberto,Isabel,Francisco,Diana,Alejandro,Valentina,Valeria,Ariana';
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



DECLARE @oi        INT = 1;
DECLARE @cli_count INT = (SELECT COUNT(*) FROM clientes);
DECLARE @pro_count INT = (SELECT COUNT(*) FROM productos);
DECLARE @estados   TABLE (idx INT IDENTITY, val NVARCHAR(30));
 
INSERT INTO @estados VALUES ('pendiente'),('confirmada'),('procesando'),
                             ('enviada'),('entregada'),('cancelada');
 
DECLARE @estado_cnt INT = (SELECT COUNT(*) FROM @estados);
 
WHILE @oi <= 5000
BEGIN
    DECLARE @cli_id  INT      = CAST(RAND(CHECKSUM(NEWID())) * @cli_count AS INT) + 1;
    DECLARE @est_val NVARCHAR(30) = (SELECT val FROM @estados
                                     WHERE idx = CAST(RAND(CHECKSUM(NEWID())) * @estado_cnt AS INT) + 1);
    DECLARE @fec_ord DATETIME2 = DATEADD(MINUTE,
                                    -CAST(RAND(CHECKSUM(NEWID())) * 525600 AS INT),
                                    SYSUTCDATETIME());
 
    INSERT INTO ordenes (cliente_id, fecha, estado, subtotal, impuestos, total)
    VALUES (@cli_id, @fec_ord, @est_val, 0, 0, 0);
 
    DECLARE @ord_id INT = SCOPE_IDENTITY();
 
    DECLARE @lineas INT = CAST(RAND(CHECKSUM(NEWID())) * 4 AS INT) + 2;
    DECLARE @li     INT = 1;
    DECLARE @sub_total DECIMAL(12,2) = 0;
 
    WHILE @li <= @lineas
    BEGIN
        DECLARE @prod_id  INT            = CAST(RAND(CHECKSUM(NEWID())) * @pro_count AS INT) + 1;
        DECLARE @qty      INT            = CAST(RAND(CHECKSUM(NEWID())) * 9 AS INT) + 1;
        DECLARE @p_unit   DECIMAL(10,2)  = (SELECT precio FROM productos WHERE id = @prod_id);
        DECLARE @lin_sub  DECIMAL(12,2)  = @qty * @p_unit;
 
        INSERT INTO detalle_orden (orden_id, producto_id, cantidad, precio_unitario, subtotal)
        VALUES (@ord_id, @prod_id, @qty, @p_unit, @lin_sub);
 
        SET @sub_total += @lin_sub;
        SET @li += 1;
    END
 
    DECLARE @imp   DECIMAL(12,2) = ROUND(@sub_total * 0.16, 2);
    DECLARE @tot   DECIMAL(12,2) = @sub_total + @imp;
 
    UPDATE ordenes
    SET subtotal = @sub_total, impuestos = @imp, total = @tot
    WHERE id = @ord_id;
 
    SET @oi += 1;
END
GO
 
SELECT * FROM ordenes;
GO
SELECT * FROM detalle_orden;
GO

DECLARE @metodos TABLE (idx INT IDENTITY, val NVARCHAR(50));
INSERT INTO @metodos VALUES ('TDC'),('TDD'),
                             ('paypal'),('transferencia'),('efectivo');
DECLARE @met_cnt INT = (SELECT COUNT(*) FROM @metodos);
 
DECLARE @pag_estados TABLE (idx INT IDENTITY, val NVARCHAR(30));
INSERT INTO @pag_estados VALUES ('completado'),('completado'),('completado'),
                                 ('fallido'),('pendiente'),('procesando');
DECLARE @pest_cnt INT = (SELECT COUNT(*) FROM @pag_estados);
 
INSERT INTO pagos (orden_id, metodo, monto, fecha, estado)
SELECT
    o.id,
    (SELECT val FROM @metodos WHERE idx = (ABS(CHECKSUM(NEWID())) % @met_cnt) + 1),
    o.total,
    DATEADD(MINUTE, CAST(RAND(CHECKSUM(NEWID())) * 1440 AS INT), o.fecha),
    (SELECT val FROM @pag_estados WHERE idx = (ABS(CHECKSUM(NEWID())) % @pest_cnt) + 1)
FROM ordenes o
WHERE o.id <= 5000;
GO

