USE master;
GO
 
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'bd_ecommerce')
BEGIN
    ALTER DATABASE bd_ecommerce SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE bd_ecommerce;
END
GO
 

CREATE DATABASE bd_ecommerce
    COLLATE SQL_Latin1_General_CP1_CI_AS;
GO
 
USE bd_ecommerce;
GO

CREATE TABLE categorias (
    id          INT             NOT NULL IDENTITY(1,1),
    nombre      NVARCHAR(100)   NOT NULL,
    descripcion NVARCHAR(500)   NULL,
 
    CONSTRAINT PK_categorias PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_categorias_nombre UNIQUE (nombre)
);
GO

CREATE TABLE productos (
    id              INT             NOT NULL IDENTITY(1,1),
    sku             NVARCHAR(50)    NOT NULL,
    nombre          NVARCHAR(200)   NOT NULL,
    descripcion     NVARCHAR(1000)  NULL,
    categoria_id    INT             NOT NULL,
    precio          DECIMAL(10, 2)  NOT NULL,
    stock           INT             NOT NULL DEFAULT 0,
    activo          BIT             NOT NULL DEFAULT 1,
    fecha_creacion  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
 
    CONSTRAINT PK_productos            PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_productos_sku        UNIQUE (sku),
    CONSTRAINT FK_productos_categorias FOREIGN KEY (categoria_id)
        REFERENCES categorias (id),
    CONSTRAINT CK_productos_precio     CHECK (precio >= 0),
    CONSTRAINT CK_productos_stock      CHECK (stock  >= 0)
);
GO