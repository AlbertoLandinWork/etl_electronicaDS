USE mibase_m3;

# 6. Normalizar los nombres de los campos y colocar el tipo de dato adecuado para cada uno en cada una de las tablas. 
# Descartar columnas que consideres que no tienen relevancia.

-- CALENDARIO
-- Corregir nombre id
DESCRIBE CALENDARIO;
SELECT * FROM CALENDARIO;
ALTER TABLE CALENDARIO CHANGE id IdCalendario INT(15) NOT NULL;

-- CANAL VENTA
SELECT * FROM CANAL_VENTA;
DESCRIBE CANAL_VENTA;


-- CLIENTE
-- MODIFICAR NOMBRE ID
-- liminar columna 10
-- Sobre tablas 'x' y 'y' crear nuevas columnas para remplazarlas, con el nombre y tipo de dato correcto, y remplazar las comas por puntos.
DESCRIBE CLIENTE;
SELECT * FROM CLIENTE;
ALTER TABLE CLIENTE CHANGE ID IdCliente INT(15) NOT NULL;
ALTER TABLE CLIENTE DROP col10;
ALTER TABLE CLIENTE DROP LATITUD;
ALTER TABLE CLIENTE DROP LONGITUD;
ALTER TABLE CLIENTE ADD Latitud DECIMAL(13,10) NOT NULL DEFAULT 0 AFTER Y;
ALTER TABLE CLIENTE ADD Longitud DECIMAL(13,10) NOT NULL DEFAULT 0 AFTER Latitud;
UPDATE CLIENTE SET X = '0' WHERE X = '';
UPDATE CLIENTE SET Y = '0' WHERE Y = '';
UPDATE CLIENTE SET LATITUD = REPLACE(Y, ',', '.');
UPDATE CLIENTE SET LONGITUD = REPLACE(X, ',', '.');
ALTER TABLE CLIENTE DROP X;
ALTER TABLE CLIENTE DROP Y;
UPDATE CLIENTE SET PROVINCIA = 'Sin dato' WHERE PROVINCIA = '';
UPDATE CLIENTE SET NOMBRE_Y_APELLIDO = 'Sin dato' WHERE NOMBRE_Y_APELLIDO = '';
UPDATE CLIENTE SET DOMICILIO = 'Sin dato' WHERE DOMICILIO = '';
UPDATE CLIENTE SET TELEFONO = '0' WHERE TELEFONO = '';
SELECT * FROM CLIENTE WHERE TELEFONO = '0';
ALTER TABLE CLIENTE CHANGE Telefono Telefono int(15) NOT NULL DEFAULT 0;
ALTER TABLE CLIENTE CHANGE Edad Edad int(15) NULL DEFAULT NULL;
UPDATE CLIENTE SET LOCALIDAD = 'Sin dato' WHERE LOCALIDAD = '';
SELECT * FROM CLIENTE WHERE Localidad = '';

SELECT COUNT(IDCLIENTE) NUM_ID FROM CLIENTE
GROUP BY IDCLIENTE
HAVING NUM_ID > 1;


-- COMPRA
SELECT * FROM COMPRA;
DESCRIBE COMPRA;
SELECT * FROM COMPRA WHERE IDCOMPRA = '' OR ISNULL(IDCOMPRA);
SELECT * FROM COMPRA WHERE FECHA = '' OR ISNULL(FECHA);
SELECT * FROM COMPRA WHERE IDPRODUCTO = '' OR ISNULL(IDPRODUCTO);
SELECT * FROM COMPRA WHERE CANTIDAD = '' OR ISNULL(CANTIDAD);
SELECT * FROM COMPRA WHERE PRECIO = '' OR ISNULL(PRECIO);
SELECT * FROM COMPRA WHERE IDPROVEEDOR = '' OR ISNULL(IDPROVEEDOR);

SELECT COUNT(IdCompra) NUM_D_IDS FROM COMPRA
GROUP BY IdCompra
HAVING NUM_D_IDS > 1;

-- EMPLEADO
-- MODIFICAR SALARIO2 PARA QUE TENGA EL NOMBRE Y EL TIPO DE DATO CORRECTO
DESCRIBE EMPLEADO;
SELECT * FROM EMPLEADO;
ALTER TABLE EMPLEADO CHANGE SALARIO2 SALARIO DECIMAL(10,2);


-- IDS DUPLICADOS EMPLEADO
SELECT COUNT(IdEmpleado) NUM_D_IDS FROM EMPLEADO
GROUP BY IdEmpleado
HAVING NUM_D_IDS > 1;

SELECT idempleado 
    FROM (SELECT `idEmpleado`, COUNT(`idempleado`) num_id
        FROM `empleado`
        GROUP BY `idempleado`
        HAVING num_id > 1) AS id_duplicados;
-- esta consulta devuelve los datos de los empleados con id duplicados
SELECT * FROM `empleado`
    JOIN (SELECT `idempleado`, COUNT(`idempleado`) num_id
        FROM `empleado`
        GROUP BY `idempleado`
        HAVING num_id > 1) AS `duplicado`
    ON `empleado`.`idempleado` = `duplicado`.`idempleado`
    ORDER BY `empleado`.`idempleado` ASC;
-- Crear una nueva columna que almacenara el id_sucursal en la tabla empleado.
ALTER TABLE `empleado` ADD `IdSucursal` INT NULL DEFAULT '0' AFTER `sucursal`;
SELECT * FROM EMPLEADO;
UPDATE empleado SET sucursal = 'Mdq 1' WHERE Sucursal = 'Mdq1';
UPDATE empleado SET sucursal = 'Mdq 2' WHERE Sucursal = 'Mdq2';
UPDATE empleado SET sucursal = 'Rosario 1' WHERE Sucursal = 'Rosario1';
UPDATE empleado SET sucursal = 'Rosario 2' WHERE Sucursal = 'Rosario2 ';
UPDATE sucursal SET sucursal = 'Mdq 1' WHERE Sucursal = 'Mdq1';
UPDATE sucursal SET sucursal = 'Mdq 2' WHERE Sucursal = 'Mdq2';
UPDATE sucursal SET sucursal = 'Rosario 1' WHERE Sucursal = 'Rosario1';
UPDATE sucursal SET sucursal = 'Rosario 2' WHERE Sucursal = 'Rosario2 ';
UPDATE sucursal SET sucursal = 'Mendoza 1' WHERE Sucursal = 'Mendoza1';
UPDATE sucursal SET sucursal = 'Mendoza 2' WHERE Sucursal = 'Mendoza2';
UPDATE empleado SET sucursal = 'Córdoba Quiroz' WHERE Sucursal = 'Cordoba Quiroz';
UPDATE empleado e JOIN sucursal s
	ON (e.sucursal = s.sucursal)
SET e.idsucursal = s.idsucursal;

-- eliminación columna sucursal
ALTER TABLE `empleado` DROP `sucursal`;
SELECT * FROM `empleado`;
-- CREAR COLUMNA CO0DIGO EMPLEADO
ALTER TABLE `empleado` ADD `codigoEmpleado` INTEGER NULL DEFAULT '0' AFTER `idempleado`;
UPDATE `empleado` SET `codigoempleado` = `idempleado`;
UPDATE `empleado` SET `idempleado` = ((idsucursal * 1000000) + codigoempleado);

-- CHEQUEO DE DUPLICADOS
SELECT `idempleado`, COUNT(`idempleado`) num_id
    FROM `empleado`
    GROUP BY `idempleado`
    HAVING num_id > 1;
SELECT * FROM `empleado`
    JOIN (SELECT `codigoempleado`, COUNT(`codigoempleado`) num_id
        FROM `empleado`
        GROUP BY `codigoempleado`
        HAVING num_id > 1) AS `duplicado`
    ON `empleado`.`codigoempleado` = `duplicado`.`codigoempleado`
    ORDER BY `empleado`.`codigoempleado` ASC;

-- Modificar la llave foranea de empleado en la tabla venta.
UPDATE `venta` SET `idempleado` = ((idsucursal * 1000000) + idempleado);



-- GASTO
SELECT * FROM GASTO;
DESCRIBE GASTO;
SELECT COUNT(IDGASTO) AS NUM_IDS FROM GASTO
GROUP BY IDGASTO
HAVING NUM_IDS > 1;

-- PRODUCTO
-- CAMBIAR EL NOMBRE DE LA COLUMNA CONCEPTO Y EL NOMBRE Y TIPO DE DATO DE PRECIO2
SELECT * FROM PRODUCTO;
DESCRIBE PRODUCTO;
ALTER TABLE PRODUCTO CHANGE PRODUCTO Producto VARCHAR(100);
ALTER TABLE PRODUCTO ADD Precio DECIMAL(15,2) NOT NULL DEFAULT 0 AFTER Precio2;
UPDATE PRODUCTO SET PRECIO = REPLACE(PRECIO2, ',','.');
ALTER TABLE PRODUCTO DROP PRECIO2;
SELECT COUNT(IDPRODUCTO) NUM_IDS FROM PRODUCTO
GROUP BY IDPRODUCTO
HAVING NUM_IDS > 1;

-- PROVEEDOR
SELECT * FROM PROVEEDOR;
DESCRIBE PROVEEDOR;
UPDATE PROVEEDOR SET NOMBRE = 'Sin dato' WHERE NOMBRE = ''; 
SELECT COUNT(IDPROVEEDOR) NUM_IDS FROM PROVEEDOR
GROUP BY IDPROVEEDOR
HAVING NUM_IDS > 1;

-- SUCURSAL 
-- MODIFICAR NOMBRE DE ID  MODIFICAR NOMBRE Y TIPO DE DATO DE LATITUD2 Y LONGITUD2
DESCRIBE SUCURSAL;
SELECT * FROM SUCURSAL;
ALTER TABLE SUCURSAL CHANGE ID IdSucursal INT(11);
ALTER TABLE SUCURSAL ADD Latitud DECIMAL(13,10) NOT NULL DEFAULT 0 AFTER Latitud2;
ALTER TABLE SUCURSAL ADD Longitud DECIMAL(13,10) NOT NULL DEFAULT 0 AFTER Longitud2;
UPDATE SUCURSAL SET LATITUD = REPLACE(Latitud2, ',', '.');
UPDATE SUCURSAL SET LONGITUD = REPLACE(Longitud2, ',', '.');
ALTER TABLE SUCURSAL DROP LATITUD2;
ALTER TABLE SUCURSAL DROP LONGITUD2;
SELECT COUNT(IDSUCURSAL) NUM_IDS FROM SUCURSAL
GROUP BY IDSUCURSAL
HAVING NUM_IDS > 1;
-- TIPO_GASTO
-- 
SELECT * FROM TIPO_GASTO;
DESCRIBE TIPO_GASTO;
SELECT COUNT(IDTIPOGASTO) NUM_IDS FROM TIPO_GASTO
GROUP BY IDTIPOGASTO
HAVING NUM_IDS > 1;
-- VENTA
-- CONVERTIR PRECIO A DECIMAL Y CANTIDAD A INT
SELECT * FROM VENTA;
DESCRIBE VENTA;
UPDATE VENTA SET PRECIO = '0' WHERE PRECIO = '';
UPDATE VENTA SET CANTIDAD = '0' WHERE CANTIDAD = CHAR(13);
ALTER TABLE VENTA CHANGE Precio Precio DECIMAL(10,2) NOT NULL;
ALTER TABLE VENTA CHANGE Cantidad Cantidad INT(30) NOT NULL;
-- Llenar datos faltantes de Precio en venta, utilizando precio en producto
UPDATE venta v
        JOIN
    producto p ON (v.IdProducto = p.IdProducto) 
SET 
    v.Precio = p.Precio
WHERE
    v.Precio = 0;

-- CREA TABLA AUXILIAR PARA DATOS CON PROBLEMAS EN CANTIDAD DE VENTA
DROP TABLE IF EXISTS `aux_venta`;
CREATE TABLE IF NOT EXISTS `aux_venta` (                                                                               -- <------- TABLE AUX VENTA
  `IdVenta`				INTEGER,
  `Fecha` 				DATE NOT NULL,
  `Fecha_Entrega` 		DATE NOT NULL,
  `IdCanal`			INTEGER,
  `IdCliente`			INTEGER, 
  `IdSucursal`			INTEGER,
  `IdEmpleado`			INTEGER,
  `IdProducto`			INTEGER,
  `Precio`				FLOAT,
  `Cantidad`			INTEGER,
  `Motivo`				INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO AUX_VENTA (IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad, Motivo)
SELECT IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, 0, 1
FROM venta WHERE Cantidad = 0 or Cantidad is null;
SELECT * FROM AUX_VENTA;
SELECT * FROM VENTA;
UPDATE venta SET Cantidad = 1 WHERE Cantidad = 0 or Cantidad is null;
SELECT COUNT(IDVENTA) NUM_IDS FROM VENTA
GROUP BY IDVENTA
HAVING NUM_IDS > 1;                                                                                                        -- <------- TABLE AUX VENTA



-- CAPITALIZAR TABLAS
UPDATE cliente SET 	Provincia = UC_Words(TRIM(Provincia)),
					Localidad = UC_Words(TRIM(Localidad)),
                    Domicilio = UC_Words(TRIM(Domicilio)),
                    Nombre_y_Apellido = UC_Words(TRIM(Nombre_y_Apellido));
					
UPDATE sucursal SET Provincia = UC_Words(TRIM(Provincia)),
					Localidad = UC_Words(TRIM(Localidad)),
                    Domicilio = UC_Words(TRIM(Domicilio)),
                    Sucursal = UC_Words(TRIM(Sucursal));
					
UPDATE proveedor SET Provincia = UC_Words(TRIM(Provincia)),
					Ciudad = UC_Words(TRIM(Ciudad)),
                    Departamento = UC_Words(TRIM(Departamento)),
                    Pais = UC_Words(TRIM(Pais)),
                    Nombre = UC_Words(TRIM(Nombre)),
                    Domicilio = UC_Words(TRIM(Domicilio));

UPDATE producto SET Producto = UC_Words(TRIM(Producto)),
					Tipo = UC_Words(TRIM(Tipo));
					
UPDATE empleado SET Sucursal = UC_Words(TRIM(Sucursal)),
                    Sector = UC_Words(TRIM(Sector)),
                    Cargo = UC_Words(TRIM(Cargo)),
                    Nombre = UC_Words(TRIM(Nombre)),
                    Apellido = UC_Words(TRIM(Apellido));
                    
-- Es necesario contar con una tabla de localidades del país con el fin de evaluar la apertura de una nueva sucursal y mejorar nuestros datos. 
-- A partir de los datos en las tablas cliente, sucursal y proveedor hay que generar una tabla definitiva de Localidades y Provincias. 
-- Utilizando la nueva tabla de Localidades controlar y corregir (Normalizar) los campos Localidad y Provincia de las tablas cliente, sucursal y proveedor.

-- Pais -> provincia -> municipio -> 
-- PROVINCIA = ESTADO        LOCALIDAD = CIUDAD     DEPARTAMENTO 

-- Rellenar la tabla auxiliar







-- Normalizar las tablas: surcursal(localidad, provincia), cliente(localidad, provincia), proveerdor(cidudad, provincia).
SELECT DISTINCT `localidad`, `provincia`, `localidad`, `provincia`, 0 FROM `cliente`
UNION
SELECT DISTINCT `localidad`, `provincia`, `localidad`, `provincia`, 0 FROM `sucursal`
UNION
SELECT DISTINCT `ciudad`, `provincia`, `ciudad`, `provincia`, 0 FROM `proveedor`
ORDER BY 2, 1;

DROP TABLE IF EXISTS `aux_localidad`;
CREATE TABLE IF NOT EXISTS `aux_localidad` (
	`localidad_original`	VARCHAR(80),
	`provincia_original`	VARCHAR(50),
	`localidad_normalizada`	VARCHAR(80),
	`provincia_normalizada`	VARCHAR(50),
	`id_localidad`			INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;


INSERT INTO `aux_localidad` (`localidad_original`, `provincia_original`, `localidad_normalizada`, `provincia_normalizada`, `id_localidad`)
SELECT DISTINCT `localidad`, `provincia`, `localidad`, `provincia`, 0 FROM `cliente`
UNION
SELECT DISTINCT `localidad`, `provincia`, `localidad`, `provincia`, 0 FROM `sucursal`
UNION
SELECT DISTINCT `ciudad`, `provincia`, `ciudad`, `provincia`, 0 FROM `proveedor`
ORDER BY 2, 1;

SELECT * FROM `aux_localidad`;


UPDATE `aux_localidad` SET provincia_normalizada = 'Buenos Aires'
WHERE provincia_original IN ('Caba',
                             'C Debuenos Aires',
                             'Bs As',
                             'Bs.As.',
                             'Buenos Aires',
                             'B. Aires',
                             'B.Aires',
                             'Provincia De Buenos Aires',
                             'Prov De Bs As',
                             'Ciudad De Buenos Aires',
                             'Pcia Bs As',
                             'Pcia Bs As',
                             'Prov De Bs As.');

SELECT DISTINCT(`provincia_normalizada`) FROM `aux_localidad`;

UPDATE `aux_localidad` SET `localidad_normalizada` = 'Capítal Federal'
WHERE `localidad_original` IN ('Boca De Atencion Monte Castro',
                            'Caba',
                            'Cap.   Federal',
                            'Cap. Fed.',
                            'Capfed',
                            'Capital',
                            'Capital Federal',
                            'Cdad De Buenos Aires',
                            'Ciudad De Buenos Aires')
AND `provincia_normalizada` = 'Buenos Aires';

SELECT DISTINCT(`localidad_normalizada`) FROM `aux_localidad` ORDER BY `localidad_normalizada`;

UPDATE `aux_localidad` SET localidad_normalizada = 'Córdoba'
WHERE localidad_original IN ('Coroba',
                            'Cordoba',
							'Cã³rdoba')
AND provincia_normalizada = 'Córdoba';


-- Crear dos tablas: tabla provincia (id_provincia, provincia), tabla localidad (id_localidad, localidad, id_provincia).
CREATE TABLE IF NOT EXISTS `localidad` (
  `id_localidad` int(11) NOT NULL AUTO_INCREMENT,
  `localidad` varchar(80) NOT NULL,
  `provincia` varchar(80) NOT NULL,
  `id_provincia` int(11) NOT NULL,
  PRIMARY KEY (`id_localidad`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;


CREATE TABLE IF NOT EXISTS `provincia` (
  `id_provincia` int(11) NOT NULL AUTO_INCREMENT,
  `provincia` varchar(50) NOT NULL,
  PRIMARY KEY (`id_provincia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;




-- Llenar las tablas.
SELECT	DISTINCT localidad_normalizada, provincia_normalizada, 0
FROM aux_localidad
ORDER BY provincia_normalizada, localidad_normalizada;

SELECT DISTINCT provincia_normalizada
FROM aux_localidad
ORDER BY provincia_normalizada;

INSERT INTO localidad (localidad, provincia, id_provincia)
SELECT	DISTINCT localidad_normalizada, provincia_normalizada, 0
FROM aux_localidad
ORDER BY provincia_normalizada, localidad_normalizada;


SELECT * FROM `localidad`;


INSERT INTO provincia (provincia)
SELECT DISTINCT Provincia_Normalizada
FROM aux_localidad
ORDER BY Provincia_Normalizada;

SELECT * FROM `provincia`;


UPDATE localidad l JOIN provincia p
	ON (l.provincia = p.provincia)
SET l.id_provincia = p.id_provincia;

SELECT * FROM `aux_localidad`;

UPDATE aux_localidad a
        JOIN
    localidad l ON (l.localidad = a.localidad_normalizada
        AND a.provincia_normalizada = l.provincia) 
SET 
    a.id_localidad = l.id_localidad;


-- Modificar las tablas surcursal(localidad, provincia), cliente(localidad, provincia), proveerdor(cidudad, provincia) 
-- para acceder a la entidad geografia de mayor jerarquia mediante de la localidad.
ALTER TABLE `cliente` ADD `id_localidad` INT NOT NULL DEFAULT '0' AFTER `localidad`;
ALTER TABLE `proveedor` ADD `id_localidad` INT NOT NULL DEFAULT '0' AFTER `departamento`;

UPDATE cliente c JOIN aux_localidad a
	ON (c.provincia = a.provincia_original AND c.localidad = a.localidad_original)
SET c.id_localidad = a.id_localidad;


ALTER TABLE SUCURSAL ADD `id_localidad` INTEGER NOT NULL DEFAULT 0 AFTER `localidad`;

UPDATE sucursal s JOIN aux_localidad a
	ON (s.provincia = a.provincia_original AND s.localidad = a.localidad_original)
SET s.id_localidad = a.id_localidad;

SHOW FULL COLUMNS FROM sucursal;

SELECT * FROM SUCURSAL;

UPDATE proveedor p JOIN aux_localidad a
	ON (p.provincia = a.provincia_original AND p.ciudad = a.localidad_original)
SET p.id_localidad = a.id_localidad;


SELECT * FROM `cliente`;

SELECT * FROM `sucursal`;

SELECT * FROM `proveedor`;


ALTER TABLE `cliente`
  DROP `Provincia`,
  DROP `Localidad`;

ALTER TABLE `proveedor`
  DROP `Ciudad`,
  DROP `Provincia`,
  DROP `Pais`,
  DROP `Departamento`;

ALTER TABLE `sucursal`
  DROP `Localidad`,
  DROP `Provincia`;
  
ALTER TABLE `localidad`
  DROP `Provincia`;

SELECT * FROM `cliente`;
SELECT * FROM `proveedor`;
SELECT * FROM `sucursal`;
SELECT * FROM `localidad`;
SELECT * FROM `provincia`;







-- Discretizacion de la edad en tabla cliente
DESCRIBE CLIENTE;
SELECT * FROM CLIENTE;
DESCRIBE CLIENTE;


ALTER TABLE CLIENTE DROP RangoEdad;
ALTER TABLE CLIENTE ADD RangoEdad VARCHAR(50) NOT NULL DEFAULT 'Sin dato' AFTER EDAD;

UPDATE CLIENTE SET RangoEdad = 'De 10 a 20' WHERE EDAD >= 10 AND EDAD <= 20;
UPDATE CLIENTE SET RangoEdad = 'De 20 a 30' WHERE EDAD >= 20 AND EDAD <= 30;
UPDATE CLIENTE SET RangoEdad = 'De 30 a 40' WHERE EDAD >= 30 AND EDAD <= 40;
UPDATE CLIENTE SET RangoEdad = 'De 40 a 50' WHERE EDAD >= 40 AND EDAD <= 50;
UPDATE CLIENTE SET RangoEdad = 'De 50 A 60' WHERE EDAD >= 50 AND EDAD <= 60;
UPDATE CLIENTE SET RangoEdad = 'De 60 a 70' WHERE EDAD >= 60 AND EDAD <= 70;
ALTER TABLE CLIENTE DROP EDAD;


SELECT * FROM PROVEEDOR;
SELECT * FROM CLIENTE;


select ciudad, provincia, departamento from proveedor;