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

