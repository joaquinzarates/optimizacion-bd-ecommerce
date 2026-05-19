IF EXISTS (SELECT name FROM sys.databases WHERE name = 'bd_ecommerce_alt')
BEGIN
    ALTER DATABASE bd_ecommerce_alt SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE bd_ecommerce_alt;
END
GO
 

CREATE DATABASE bd_ecommerce_alt
    COLLATE SQL_Latin1_General_CP1_CI_AS;
GO
 
USE bd_ecommerce_alt;
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

CREATE TABLE clientes (
    id              INT             NOT NULL IDENTITY(1,1),
    nombre          NVARCHAR(100)   NOT NULL,
    apellido        NVARCHAR(100)   NOT NULL,
    correo          NVARCHAR(200)   NOT NULL,
    telefono        NVARCHAR(20)    NULL,
    fecha_registro  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    ciudad          NVARCHAR(100)   NULL,
 
    CONSTRAINT PK_clientes         PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_clientes_correo  UNIQUE (correo)
);
GO


CREATE TABLE ordenes (
    id          INT             NOT NULL IDENTITY(1,1),
    cliente_id  INT             NOT NULL,
    fecha       DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    estado      NVARCHAR(30)    NOT NULL DEFAULT 'pendiente',
    subtotal    DECIMAL(12, 2)  NOT NULL,
    impuestos   DECIMAL(12, 2)  NOT NULL,
    total       DECIMAL(12, 2)  NOT NULL,
 
    CONSTRAINT PK_ordenes         PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_ordenes_clientes FOREIGN KEY (cliente_id)
        REFERENCES clientes (id),
    CONSTRAINT CK_ordenes_estado   CHECK (estado IN (
        'pendiente', 'confirmada', 'procesando',
        'enviada', 'entregada', 'cancelada', 'reembolsada'
    )),
    CONSTRAINT CK_ordenes_subtotal CHECK (subtotal  >= 0),
    CONSTRAINT CK_ordenes_impuesto CHECK (impuestos >= 0),
    CONSTRAINT CK_ordenes_total    CHECK (total     >= 0)
);
GO

CREATE TABLE detalle_orden (
    id              INT             NOT NULL IDENTITY(1,1),
    orden_id        INT             NOT NULL,
    producto_id     INT             NOT NULL,
    cantidad        INT             NOT NULL,
    precio_unitario DECIMAL(10, 2)  NOT NULL,
    subtotal        DECIMAL(12, 2)  NOT NULL,
 
    CONSTRAINT PK_detalle_orden           PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_detalle_orden_ordenes   FOREIGN KEY (orden_id)
        REFERENCES ordenes (id),
    CONSTRAINT FK_detalle_orden_productos FOREIGN KEY (producto_id)
        REFERENCES productos (id),
    CONSTRAINT CK_detalle_orden_cantidad  CHECK (cantidad        > 0),
    CONSTRAINT CK_detalle_orden_precio    CHECK (precio_unitario >= 0),
    CONSTRAINT CK_detalle_orden_subtotal  CHECK (subtotal        >= 0)
);
GO


CREATE TABLE pagos (
    id       INT             NOT NULL IDENTITY(1,1),
    orden_id INT             NOT NULL,
    metodo   NVARCHAR(50)    NOT NULL,
    monto    DECIMAL(12, 2)  NOT NULL,
    fecha    DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    estado   NVARCHAR(30)    NOT NULL DEFAULT 'pendiente',
 
    CONSTRAINT PK_pagos         PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_pagos_ordenes FOREIGN KEY (orden_id)
        REFERENCES ordenes (id),
    CONSTRAINT CK_pagos_metodo  CHECK (metodo IN (
        'TDC', 'TDD', 'paypal',
        'transferencia','efectivo'
    )),
    CONSTRAINT CK_pagos_estado  CHECK (estado IN (
        'pendiente', 'procesando', 'completado',
        'fallido', 'reembolsado'
    )),
    CONSTRAINT CK_pagos_monto   CHECK (monto > 0)
);
GO