USE MIBASE_M3;

SELECT * FROM VENTA;

SELECT IDPRODUCTO, AVG(PRECIO) AS PROMEDIO, AVG (PRECIO) + 3 * STDDEV(PRECIO) AS MAX FROM VENTA
GROUP BY IDPRODUCTO;


-- CONSULTA PARA OUTLIERS DE PRECIO
SELECT V.*, LS.PROMEDIO, LS.MAXIMO FROM VENTA V 
JOIN(SELECT IDPRODUCTO, AVG(PRECIO) AS PROMEDIO, AVG (PRECIO) + 3 * STDDEV(PRECIO) AS MAXIMO FROM VENTA
GROUP BY IDPRODUCTO) AS LS
ON V.IDPRODUCTO = LS.IDPRODUCTO
WHERE PRECIO > MAXIMO;

-- CONSULTA PARA OUTLIERS DE CANTIDAD
SELECT V.*, LS.PROMEDIO, LS.MAXIMO FROM VENTA V 
JOIN(SELECT IDPRODUCTO, AVG(CANTIDAD) AS PROMEDIO, AVG (CANTIDAD) + 3 * STDDEV(CANTIDAD) AS MAXIMO FROM VENTA
GROUP BY IDPRODUCTO) AS LS
ON V.IDPRODUCTO = LS.IDPRODUCTO
WHERE CANTIDAD > MAXIMO;

-- INSERT OUTLIERS CANTIDAD
INSERT INTO AUX_VENTA (IDVENTA, FECHA, FECHA_ENTREGA, IDCANAL, IDCLIENTE, IDSUCURSAL, IDEMPLEADO, IDPRODUCTO, PRECIO, CANTIDAD, MOTIVO)
SELECT V.IDVENTA, V.FECHA, V.FECHA_ENTREGA, V.IDCANAL, V.IDCLIENTE, V.IDSUCURSAL, V.IDEMPLEADO, V.IDPRODUCTO, V.PRECIO, V.CANTIDAD, 2
FROM VENTA V 
JOIN (SELECT IDPRODUCTO, AVG(CANTIDAD) AS PROMEDIO, STDDEV(CANTIDAD) AS DES FROM VENTA GROUP BY IDPRODUCTO) V2
ON (V.IDPRODUCTO = V2.IDPRODUCTO)
WHERE V.CANTIDAD > (V2.PROMEDIO + (3 * V2.DES)) OR V.CANTIDAD < 0;

-- INSERT OUTLIERS PRECIO
INSERT INTO AUX_VENTA (IDVENTA, FECHA, FECHA_ENTREGA, IDCANAL, IDCLIENTE, IDSUCURSAL, IDEMPLEADO, IDPRODUCTO, PRECIO, CANTIDAD, MOTIVO)
SELECT V.IDVENTA, V.FECHA, V.FECHA_ENTREGA, V.IDCANAL, V.IDCLIENTE, V.IDSUCURSAL, V.IDEMPLEADO, V.IDPRODUCTO, V.PRECIO, V.CANTIDAD, 3
FROM VENTA V 
JOIN(SELECT IDPRODUCTO, AVG(PRECIO) AS PROMEDIO, AVG (PRECIO) + 3 * STDDEV(PRECIO) AS MAXIMO FROM VENTA GROUP BY IDPRODUCTO) AS LS
ON V.IDPRODUCTO = LS.IDPRODUCTO
WHERE PRECIO > MAXIMO OR PRECIO <= 0;

-- MARCAR OUTLIERS

ALTER TABLE VENTA ADD Outlier INT NOT NULL DEFAULT '1' AFTER CANTIDAD;

UPDATE VENTA V JOIN AUX_VENTA A
ON (V.IDVENTA = A.IDVENTA AND A.MOTIVO IN (2,3))
SET V.OUTLIER = 0;

SELECT * FROM VENTA WHERE OUTLIER = 0;

# KPIs
-- RELACION ENTRE GASTO Y VENTA POR SUCURSAL
-- VENTA POR EMPLEADO

SELECT * FROM VENTA;

SELECT * FROM COMPRA;








