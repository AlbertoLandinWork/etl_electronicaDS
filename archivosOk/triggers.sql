USE MIBASE_M3;
-- Creamos la tabla que auditará a los usuarios que realizan cambios
DROP TABLE IF EXISTS `fact_venta_auditoria`;
CREATE TABLE IF NOT EXISTS `fact_venta_auditoria` (
	`id_fact_venta_auditoria`	INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`IdVenta`								INTEGER,
	`Fecha`								DATE,
	`Fecha_Entrega`					DATE,
	`IdCanal`								INTEGER,
	`IdCliente`							INTEGER,
	`IdEmpleado`						INTEGER,
	`IdProducto`						INTEGER,
    `Precio`								INTEGER,
	`Usuario`								VARCHAR(20),
	`FechaModificacion`			DATETIME
)ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_spanish_ci;

select * from fact_venta;

-- Creamos el trigger que se ejecutara luego de cada cambio
DROP TRIGGER fact_venta_auditoria;
CREATE TRIGGER fact_venta_auditoria AFTER INSERT ON fact_venta
FOR EACH ROW
INSERT INTO fact_venta_auditoria (IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdEmpleado, IdProducto, Precio, usuario, fechaModificacion)
VALUES (NEW.IdVenta, NEW.Fecha, NEW.Fecha_Entrega, NEW.IdCanal, NEW.IdCliente, NEW.IdEmpleado, NEW.IdProducto, NEW.Precio, CURRENT_USER,NOW());

SELECT * FROM FACT_VENTA_AUDITORIA;

INSERT INTO FACT_VENTA (IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdEmpleado, IdProducto, Precio)
SELECT IdVenta + 10000, '2021-01-01', '2021-01-05', IdCanal, IdCliente, IdEmpleado, IdProducto, Precio
FROM VENTA
WHERE FECHA = '2020-12-30';

SELECT * FROM FACT_VENTA WHERE FECHA = '2020-12-30';

-- Creamos la tabla que llevara una cuenta de los registros.
DROP TABLE IF EXISTS `fact_venta_registros`;
CREATE TABLE IF NOT EXISTS `fact_venta_registros` (
`id`				INT NOT NULL AUTO_INCREMENT,
`cantidadRegistros` INT,
`usuario`					VARCHAR(20),
`fecha`						DATETIME,
PRIMARY KEY (id)
);

SELECT * FROM FACT_VENTA_REGISTROS;
-- Creamos el trigger que se ejecutara luego de cada cambio

-- AQUI ME QUEDÉ 
DROP TRIGGER fact_venta_registros;
CREATE TRIGGER fact_venta_registros
AFTER INSERT ON fact_venta
FOR EACH ROW
INSERT INTO fact_inicial_registros (cantidadRegistros, usuarios, fecha)
VALUES ((SELECT COUNT(*) FROM fact_venta), CURRENT_USER, NOW());








-- Creamos una tabla donde podremos almacenar la cantidad de registros por día
DROP TABLE registros_tablas;
CREATE TABLE registros_tablas (
id INT NOT NULL AUTO_INCREMENT,
tabla VARCHAR(30),
fecha DATETIME,
cantidadRegistros INT,
PRIMARY KEY (id)
);

-- Esta instrucción nos permite cargar la tabla anterior y saber cual es la cantidad de registros por día.
INSERT INTO registros_tablas (tabla, fecha, cantidadRegistros)
SELECT 'venta', now(), count(*) from venta;

INSERT INTO registros_tablas (tabla, fecha, cantidadRegistros)
SELECT 'gasto', now(), count(*) from gasto; 

INSERT INTO registros_tablas (tabla, fecha, cantidadRegistros)
SELECT 'compra', now(), count(*) from compra;

SELECT * FROM REGISTROS_TABLAS;


SELECT DATE('2011-01-01 00:00:10');

-- Creamos una tabla para auditar cambios
DROP TABLE IF EXISTS `fact_venta_cambios`;
CREATE TABLE IF NOT EXISTS `fact_venta_cambios` (
  	`Fecha` 			DATE,
  	`IdCliente` 		INTEGER,
  	`IdProducto` 		INTEGER,
    `Precio`			DECIMAL(15,3),
    `Cantidad` 		INTEGER
);

-- Creamos el trigger que carga nuevos registros
DROP TRIGGER auditoria_cambios;
CREATE TRIGGER auditoria_cambios BEFORE  UPDATE ON fact_venta
FOR EACH ROW
INSERT INTO fact_venta_cambios (Fecha, IdCliente, IdProducto, Precio, Cantidad)
VALUES (NEW.Fecha, NEW.IdCliente, NEW.IdProducto, NEW.Precio, NEW.Cantidad);

SELECT * FROM FACT_VENTA_CAMBIOS;
SELECT * FROM FACT_VENTA WHERE IdVenta = 1;
UPDATE fact_venta SET Precio = 820 WHERE IDVENTA = 1;

-- Creamos el trigger que carga cambios en los registros
CREATE TRIGGER auditoria_actualizacion AFTER UPDATE ON fact_venta
FOR EACH ROW
UPDATE fact_venta_cambios
SET 
IdCliente = OLD.IdCliente, 
IdProducto = OLD.IdProducto,
IdCliente1 = NEW.IdCliente, 
IdProducto1 = NEW.IdProducto
WHERE Fecha = OLD.Fecha;




	
-- BORRA LO QUE METIMOS CON INSERT TO
DELETE FROM fact_venta  WHERE fact_venta.IdVenta in (
    SELECT c.IdVenta FROM (
        SELECT fv.idVenta FROM fact_venta fv
        JOIN fact_venta_auditoria fva ON (fv.IdVenta = fva.IdVenta)
    ) AS c
);











--            -------------------------------------------------------                 STORED PROCEDURES                ----------------------------------------------------------------------------------











-- 1 Crear un procedimiento que recibe como parametro una fecha y devuelva el listado de productos que se vendieron en esa fecha.

SELECT DISTINCT tp.TipoProducto, p.Producto
FROM fact_venta v JOIN dim_producto p
			ON (v.IdProducto = p.IdProducto AND v.Fecha = '2020-01-01')
		JOIN tipo_producto tp
			ON (p.IdTipoProducto = tp.IdTipoProducto)
ORDER BY tp.TipoProducto, p.Producto;



DROP PROCEDURE ListaProductos;
DELIMITER $$
CREATE PROCEDURE ListaProductos(IN FechaVenta DATE)
BEGIN
			SELECT DISTINCT tp.TipoProducto, p.Producto
			FROM fact_venta v JOIN dim_producto p
						ON (v.IdProducto = p.IdProducto AND v.Fecha = FechaVenta)
					JOIN tipo_producto tp
						ON (p.IdTipoProducto = tp.IdTipoProducto)
			ORDER BY tp.TipoProducto, p.Producto;
END $$
DELIMITER ;

CALL listaProductos('2020-01-01');


-- 2 -Crear una función que calcule el valor nominal de un margen bruto determinado por el usuario a partir del precio de lista de los productos.

DROP FUNCTION margenBruto;
DELIMITER $$
CREATE FUNCTION margenBruto(precio DECIMAL(15,3), margen DECIMAL(9,2)) RETURNS DECIMAL (15,3)
DETERMINISTIC -- <----- ME FUNCIONÓ PARA SOLUCIONAR ERROR 1418
BEGIN
			DECLARE margenBruto DECIMAL(15,3);
            
            SET margenBruto = precio * margen;
            
            RETURN margenBruto;
END$$
DELIMITER ;

SELECT margenBruto(100, 1.2);

SELECT PRODUCTO, margenBruto(PRECIO, 1.2) AS MARGEN FROM PRODUCTO;



-- 3 -Obtner un listado de productos de IMPRESION y utilizarlo para cálcular el valor nominal de un margen bruto del 20% de cada uno de los productos.
-- MIN 51 CODEREVIEW CLASE 6
SELECT  P.PRODUCTO, 
				PR.NOMBRE 					AS PROVEEDOR,
				C.PRECIO 						AS PrecioCompra,
                margenBruto(c.Precio, 1.3)	AS PrecioMargen
FROM COMPRA C JOIN PRODUCTO P
			ON (C.IdProducto = P.IdProducto)
            JOIN PROVEEDOR PR
            ON C.IDPROVEEDOR = PR.IDPROVEEDOR AND P.IDTIPOPRODUCTO = 8;

SELECT * FROM FACT_VENTA;
SELECT * FROM PRODUCTO;
SELECT * FROM TIPO_PRODUCTO;




-- 4 -Crear un procedimiento que permita listar los productos vendidos desde fact_inicial a partir de un "Tipo" que determine el usuario.

DROP PROCEDURE FiltrarTipo;
DELIMITER $$
CREATE PROCEDURE FiltrarTipo(tipo VARCHAR(20))
BEGIN
		SELECT DISTINCT(F.IdProducto), P.PRODUCTO, P.IDTIPOPRODUCTO, TP.TIPOPRODUCTO FROM FACT_VENTA F
		JOIN PRODUCTO P
		ON F.IDPRODUCTO = P.IDPRODUCTO
		JOIN TIPO_PRODUCTO TP 
		ON P.IDTIPOPRODUCTO = TP.IDTIPOPRODUCTO
		WHERE TIPOPRODUCTO COLLATE utf8mb4_spanish_ci LIKE CONCAT('%', tipo, '%');
END $$
DELIMITER ;

CALL FiltrarTipo('Impresión');














select * from tipo_producto;

DELIMITER $$
CREATE PROCEDURE FILTRAR2(TIPO VARCHAR(20))
BEGIN
SELECT  V.FECHA, V.FECHA_ENTREGA, V.IDCLIENTE, V.IDCANAL, V.IDSUCURSAL, P.Producto, V.PRECIO, V.CANTIDAD
FROM VENTA V 
JOIN PRODUCTO P
			ON (V.IDPRODUCTO = P.IDPRODUCTO)
JOIN TIPO_PRODUCTO TP
			ON (P.IDTIPOPRODUCTO = TP.IDTIPOPRODUCTO
			AND TIPOPRODUCTO  LIKE CONCAT('%', TIPO, '%'));
END $$
DELIMITER ;

CALL FILTRAR2('IMP');

SELECT * FROM TIPO_PRODUCTO;
SELECT * FROM PRODUCTO;

-- 5 -Crear un procedimiento que permita realizar la insercción de datos en la tabla fact_inicial.

-- 6 -Crear un procedimiento almacenado que reciba un grupo etario y devuelta el total de ventas para ese grupo.

-- 7 -Crear una variable que se pase como valor para realizar una filtro sobre Rango_etario en una consulta génerica a dim_cliente.

