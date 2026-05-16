# Diccionario de Datos : ecommerce_db
 

 
## Tabla: `categorias`
 
Catálogo maestro de categorías de productos.
 
| Columna | Tipo | Nulable | Default | Descripción |
|---|---|---|---|---|
| `id` | INT IDENTITY(1,1) | NO | — | Clave primaria autoincremental |
| `nombre` | NVARCHAR(100) | NO | — | Nombre único de la categoría |
| `descripcion` | NVARCHAR(500) | SÍ | NULL | Descripción opcional |
 
**Restricciones:** PK `PK_categorias` · UQ `UQ_categorias_nombre`
 
---
 
## Tabla: `productos`
 
Catálogo de artículos disponibles para venta.
 
| Columna | Tipo | Nulable | Default | Descripción |
|---|---|---|---|---|
| `id` | INT IDENTITY(1,1) | NO | — | Clave primaria |
| `sku` | NVARCHAR(50) | NO | — | Código único de producto (Stock Keeping Unit) |
| `nombre` | NVARCHAR(200) | NO | — | Nombre descriptivo |
| `descripcion` | NVARCHAR(1000) | SÍ | NULL | Descripción larga (no indexada) |
| `categoria_id` | INT | NO | — | FK a `categorias.id` |
| `precio` | DECIMAL(10,2) | NO | — | Precio de venta en MXN. Mínimo: 0.00 |
| `stock` | INT | NO | 0 | Unidades disponibles en almacén. Mínimo: 0 |
| `activo` | BIT | NO | 1 | 1 = visible en catálogo; 0 = descontinuado |
| `fecha_creacion` | DATETIME2 | NO | SYSUTCDATETIME() | Timestamp de creación (UTC) |
 
**Restricciones:** PK · UQ sku · FK → categorias · CK precio ≥ 0 · CK stock ≥ 0
 
---
 
## Tabla: `clientes`
 
Registro de compradores registrados en la plataforma.
 
| Columna | Tipo | Nulable | Default | Descripción |
|---|---|---|---|---|
| `id` | INT IDENTITY(1,1) | NO | — | Clave primaria |
| `nombre` | NVARCHAR(100) | NO | — | Nombre(s) del cliente |
| `apellido` | NVARCHAR(100) | NO | — | Apellido(s) del cliente |
| `correo` | NVARCHAR(200) | NO | — | Email único; se usa como login |
| `telefono` | NVARCHAR(20) | SÍ | NULL | Número de contacto con formato libre |
| `fecha_registro` | DATETIME2 | NO | SYSUTCDATETIME() | Fecha de alta en la plataforma (UTC) |
| `ciudad` | NVARCHAR(100) | SÍ | NULL | Ciudad de residencia |
 
**Restricciones:** PK · UQ correo
 
---
 
## Tabla: `ordenes`
 
Cabecera de cada transacción de compra.
 
| Columna | Tipo | Nulable | Default | Descripción |
|---|---|---|---|---|
| `id` | INT IDENTITY(1,1) | NO | — | Clave primaria |
| `cliente_id` | INT | NO | — | FK a `clientes.id` |
| `fecha` | DATETIME2 | NO | SYSUTCDATETIME() | Momento de creación de la orden (UTC) |
| `estado` | NVARCHAR(30) | NO | 'pendiente' | Ciclo de vida del pedido |
| `subtotal` | DECIMAL(12,2) | NO | — | Suma de líneas antes de impuestos |
| `impuestos` | DECIMAL(12,2) | NO | — | IVA u otros impuestos aplicados |
| `total` | DECIMAL(12,2) | NO | — | subtotal + impuestos |
 
**Estados válidos:** `pendiente` · `confirmada` · `procesando` · `enviada` · `entregada` · `cancelada` · `reembolsada`
 
**Restricciones:** PK · FK → clientes · CK estado · CK montos ≥ 0
 
---
 
## Tabla: `detalle_orden`
 
Líneas de producto incluidas en cada orden (relación N:M entre órdenes y productos).
 
| Columna | Tipo | Nullable | Default | Descripción |
|---|---|---|---|---|
| `id` | INT IDENTITY(1,1) | NO | — | Clave primaria |
| `orden_id` | INT | NO | — | FK a `ordenes.id` |
| `producto_id` | INT | NO | — | FK a `productos.id` |
| `cantidad` | INT | NO | — | Unidades pedidas (Mínimo: 1) |
| `precio_unitario` | DECIMAL(10,2) | NO | — | Precio  al momento de la compra |
| `subtotal` | DECIMAL(12,2) | NO | — | cantidad * precio_unitario |
 
**Restricciones:** PK · FK → ordenes · FK → productos · CK cantidad > 0 · CK montos ≥ 0
 
---
 
## Tabla: `pagos`
 
Registro de transacciones de cobro asociadas a órdenes.
 
| Columna | Tipo | Nulable | Default | Descripción |
|---|---|---|---|---|
| `id` | INT IDENTITY(1,1) | NO | — | Clave primaria |
| `orden_id` | INT | NO | — | FK a `ordenes.id` (relación 1:1 en el seed) |
| `metodo` | NVARCHAR(50) | NO | — | Método de pago utilizado |
| `monto` | DECIMAL(12,2) | NO | — | Importe cobrado. Mínimo: 0.01 |
| `fecha` | DATETIME2 | NO | SYSUTCDATETIME() | Timestamp del intento de cobro (UTC) |
| `estado` | NVARCHAR(30) | NO | 'pendiente' | Estado de la transacción |
 
**Métodos válidos:** `TDC` · `TDD` · `paypal` · `transferencia` · `efectivo`  
**Estados válidos:** `pendiente` · `procesando` · `completado` · `fallido` · `reembolsado`
 
**Restricciones:** PK · FK → ordenes · CK metodo · CK estado · CK monto > 0
 
---