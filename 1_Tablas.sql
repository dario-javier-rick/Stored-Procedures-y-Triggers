----------------------------------------------------------------------------------------
-- Tablas del trabajo práctico N°2

CREATE TABLE cliente
(
Nrocliente int,
Apellido char(40),
Nombre char(40),
Domicilio char(60),
Telefono char(10)
);


-- Tipo de dato enumerable de estados
-- para usar en tabla tarjeta
CREATE TYPE estados_tarjeta
AS ENUM (
		'Vigente', 
		'Suspendida', 
		'Anulada'
		);

		
CREATE TABLE tarjeta
(
Nrotarjeta char(12),
Nrocliente int,
ValidaDesde char(6),
ValidaHasta char(6),
Codseguridad char(4),
LimiteCompra decimal(7,2),
Estado estados_tarjeta --char(10)
);


CREATE TABLE comercio
(
Nrocomercio int,
Nombre char(40),
Domicilio char(60),
Codigopostal integer,
Telefono char(10)
);


CREATE TABLE consumos
(
NroOperacion int,
Nrotarjeta char(12),
NroComercio int,
Fecha timestamp,
Monto decimal (6,2),
Pagado char(1)
);


CREATE TABLE rechazos
(
NroRechazo int,
NroTarjeta char(12),
NroComercio int,
Fecha timestamp,
Monto decimal (6,2),
Motivo char(80)
);


CREATE TABLE cierres
(
Año int,
Mes int,
Terminacion int,
Fechainicio date,
Fechacierre date,
Fechavto date
);


CREATE TABLE compras 
(
Nrotarjeta char(12),
ValidaDesde char(6),
ValidaHasta char(6),
Codseguridad char(4),
NroComercio int,
Monto decimal(6,2)
);

CREATE TABLE Parametros 
(
Descripcion char(20),
Valor char(20),
Tipo char(4)
);

-- Tabla test

CREATE TABLE test
(
  Nrotarjeta character(12),
  Nrocomercio integer,
  Monto numeric,
  Codseguridad character(4)
);

-- Tablas auxiliares

CREATE TABLE motivos_rechazo
(
  idMotivo SERIAL NOT NULL,
  motivo character varying(80),
  CONSTRAINT motivos_rechazo_pkey PRIMARY KEY (idMotivo)
);

CREATE TABLE alertas 
(
-- Verificar qué datos tiene que tener esta tabla
-- Puede que idAlerta este de  más, y se pueda hacer una PK
-- con NroOperacion y esRechazo
	idalerta SERIAL NOT NULL,
	NroOperacion INTEGER,
	esRechazo BOOLEAN,
	CONSTRAINT alertas_pkey PRIMARY KEY (idalerta)
);

CREATE TABLE factura
(
  idFactura SERIAL NOT NULL,
  Nrocliente int,
  Periodo date,
  FechaVencimiento date,
-- El monto se puede calcular con un SUM sobre compras_periodo_usuario
  CONSTRAINT factura_pkey PRIMARY KEY (idFactura)
);

CREATE TABLE compras_periodo_usuario
(
  idCPU SERIAL NOT NULL,
  idFactura int,
  Nrotarjeta char(12),
  NroOperacion int,
  CONSTRAINT compras_periodo_usuario_pkey PRIMARY KEY (idCPU)
);

----------------------------------------------------------------------------------------


