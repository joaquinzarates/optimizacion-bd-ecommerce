USE bd_ecommerce_alt;
GO


CREATE NONCLUSTERED INDEX IX_productos_categoria_precio
    ON productos (categoria_id, precio)
    INCLUDE (sku, nombre, stock, activo, fecha_creacion);
GO


CREATE NONCLUSTERED INDEX IX_productos_activos_precio
    ON productos (precio, categoria_id)
    INCLUDE (sku, nombre, stock)
    WHERE activo = 1;
GO


CREATE NONCLUSTERED INDEX IX_productos_fecha_creacion
    ON productos (fecha_creacion)
    INCLUDE (sku, nombre, categoria_id, precio, stock, activo);
GO


CREATE NONCLUSTERED INDEX IX_ordenes_cliente_fecha
    ON ordenes (cliente_id, fecha)
    INCLUDE (estado, subtotal, impuestos, total);
GO


CREATE NONCLUSTERED INDEX IX_ordenes_fecha_estado
    ON ordenes (fecha, estado)
    INCLUDE (cliente_id, subtotal, impuestos, total);
GO


CREATE NONCLUSTERED INDEX IX_ordenes_entregadas
    ON ordenes (cliente_id, fecha)
    INCLUDE (total, estado)
    WHERE estado IN ('entregada', 'enviada');
GO


CREATE NONCLUSTERED INDEX IX_detalle_orden_orden_id
    ON detalle_orden (orden_id)
    INCLUDE (producto_id, cantidad, precio_unitario, subtotal);
GO


CREATE NONCLUSTERED INDEX IX_detalle_orden_producto_id
    ON detalle_orden (producto_id)
    INCLUDE (orden_id, cantidad, subtotal);
GO


CREATE NONCLUSTERED INDEX IX_pagos_orden_id
    ON pagos (orden_id)
    INCLUDE (metodo, monto, fecha, estado);
GO


CREATE NONCLUSTERED INDEX IX_pagos_completados_fecha
    ON pagos (fecha, orden_id)
    INCLUDE (metodo, monto)
    WHERE estado = 'completado';
GO


CREATE NONCLUSTERED INDEX IX_clientes_ciudad_registro
    ON clientes (ciudad, fecha_registro)
    INCLUDE (nombre, apellido, correo);
GO
