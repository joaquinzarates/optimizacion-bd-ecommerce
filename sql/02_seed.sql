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
 



