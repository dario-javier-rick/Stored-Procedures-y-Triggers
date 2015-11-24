----------------------------------------------------------------------------------------
-- Secuencias

-- Secuencias en cliente

CREATE SEQUENCE cliente_Nrocliente_seq;

ALTER SEQUENCE cliente_Nrocliente_seq OWNED BY cliente.Nrocliente;

ALTER TABLE cliente 
ALTER COLUMN Nrocliente
SET DEFAULT nextval('cliente_Nrocliente_seq');

-- Secuencias en comercio

CREATE SEQUENCE comercio_Nrocomercio_seq;

ALTER SEQUENCE comercio_Nrocomercio_seq OWNED BY comercio.Nrocomercio;

ALTER TABLE comercio
ALTER COLUMN Nrocomercio
SET DEFAULT nextval('comercio_Nrocomercio_seq');

-- Secuencias en consumos

CREATE SEQUENCE consumos_NroOperacion_seq;

ALTER SEQUENCE consumos_NroOperacion_seq OWNED BY consumos.NroOperacion;

ALTER TABLE consumos
ALTER COLUMN NroOperacion
SET DEFAULT nextval('consumos_NroOperacion_seq');

-- Secuencias en rechazos

CREATE SEQUENCE rechazos_NroRechazo_seq;

ALTER SEQUENCE rechazos_NroRechazo_seq OWNED BY rechazos.NroRechazo;

ALTER TABLE rechazos
ALTER COLUMN NroRechazo
SET DEFAULT nextval('rechazos_NroRechazo_seq');


----------------------------------------------------------------------------------------
-- Indices

CREATE INDEX Nrocliente_idx ON tarjeta (Nrocliente);
CREATE INDEX Nrotarjeta_idx ON consumos (Nrotarjeta);
CREATE INDEX NroComercio_idx ON consumos (NroComercio);
CREATE INDEX Codigopostal_idx ON comercio (Codigopostal);

----------------------------------------------------------------------------------------

-- Inserts de posibles motivos de rechazo

INSERT INTO motivos_rechazo (motivo)
VALUES
('Tarjeta no valida o no vigente');

INSERT INTO motivos_rechazo (motivo)
VALUES
('Codigo de seguridad invalido');

INSERT INTO motivos_rechazo (motivo)
VALUES
('La tarjeta se encuentra suspendida');

INSERT INTO motivos_rechazo (motivo)
VALUES
('Plazo de vigencia expirado');

INSERT INTO motivos_rechazo (motivo)
VALUES
('Supera limite de tarjeta');


----------------------------------------------------------------------------------------
-- Carga de datos

copy cliente
(nrocliente,apellido,nombre,domicilio,telefono)
from '/home/pilaga/Escritorio/clientes.csv'DELIMITERS';'CSV;

copy tarjeta
(nrotarjeta,nrocliente,validadesde,validahasta,codseguridad,limitecompra,estado)
from '/home/pilaga/Escritorio/tarjetas.csv'DELIMITERS';'CSV;

copy comercio
(nrocomercio,nombre,domicilio,codigopostal,telefono)
from '/home/pilaga/Escritorio/comercios.csv'DELIMITERS';'CSV;

copy cierres
(año,mes,terminacion,fechainicio,fechacierre,fechavto)
from '/home/pilaga/Escritorio/cierres.csv'DELIMITERS';'CSV;

copy test
(Nrotarjeta, Nrocomercio, Monto, Codseguridad )
from '/home/pilaga/Escritorio/Test.csv'DELIMITERS';'CSV;


----------------------------------------------------------------------------------------


