----------------------------------------------------------------------------------------
-- Constraints del trabajo práctico N°2

-- Constraints tabla cliente

ALTER table cliente ALTER COLUMN 
Nrocliente
SET NOT NULL;

ALTER table cliente
ADD PRIMARY KEY
( 
Nrocliente
);

ALTER table cliente ALTER COLUMN 
Apellido
SET NOT NULL;

ALTER table cliente ALTER COLUMN 
Nombre
SET NOT NULL;

-- Constraints tabla tarjeta

ALTER table tarjeta ALTER COLUMN 
Nrotarjeta
SET NOT NULL;

ALTER table tarjeta
ADD PRIMARY KEY
( 
Nrotarjeta
);

ALTER TABLE tarjeta 
ADD FOREIGN KEY
(Nrocliente) REFERENCES cliente(Nrocliente);

-- Constraints tabla comercio

ALTER table comercio 
ALTER COLUMN Nrocomercio
SET NOT NULL;

ALTER table comercio
ADD PRIMARY KEY
( 
Nrocomercio
);

-- Constraints tabla consumos

ALTER table consumos 
ALTER COLUMN NroOperacion
SET NOT NULL;

ALTER table consumos
ADD PRIMARY KEY
( 
NroOperacion
);

ALTER TABLE consumos ADD FOREIGN KEY
(Nrotarjeta) REFERENCES tarjeta(Nrotarjeta);
 
ALTER TABLE consumos ADD FOREIGN KEY
(NroComercio) REFERENCES comercio(Nrocomercio);

ALTER TABLE consumos 
ADD CONSTRAINT check_Monto 
CHECK (Monto > 0);

-- Constraints tabla rechazos

ALTER table rechazos ALTER COLUMN 
NroRechazo
SET NOT NULL;

ALTER table rechazos
ADD PRIMARY KEY
( 
NroRechazo
);

-- Esta FK esta demás si tenemos en cuenta que en la 
--tabla rechazos pueden ir números de tarjeta inválidos
--ALTER TABLE rechazos ADD FOREIGN KEY
--(NroTarjeta) REFERENCES tarjeta(Nrotarjeta);

ALTER TABLE rechazos ADD FOREIGN KEY
(NroComercio) REFERENCES comercio(Nrocomercio);

ALTER TABLE rechazos 
ADD CONSTRAINT check_Monto 
CHECK (Monto > 0);


-- Constraints tabla cierres

ALTER table cierres 
ALTER COLUMN Mes
SET NOT NULL;

ALTER table cierres 
ALTER COLUMN Año
SET NOT NULL;

ALTER table cierres 
ALTER COLUMN Terminacion
SET NOT NULL;

ALTER table cierres
ADD PRIMARY KEY
( 
Año,Mes,Terminacion
);

-- Constraints tabla compras

ALTER table compras 
ALTER COLUMN Nrotarjeta
SET NOT NULL;

ALTER table compras
ADD PRIMARY KEY
( 
Nrotarjeta
);

ALTER TABLE compras 
ADD CONSTRAINT check_Monto 
CHECK (Monto > 0);

-- Constraints tabla test

ALTER TABLE test 
ADD CONSTRAINT check_Monto 
CHECK (Monto > 0);

-- Constraints tabla alertas

ALTER TABLE alertas 
ADD CONSTRAINT NroOperacion_esRechazo
UNIQUE (NroOperacion, esRechazo); -- Verificar unique key

----------------------------------------------------------------------------------------
-- Constraints tabla factura

ALTER TABLE factura ADD FOREIGN KEY
(Nrocliente) REFERENCES cliente(Nrocliente);

----------------------------------------------------------------------------------------
-- Constraints tabla compras_periodo_usuario

ALTER TABLE compras_periodo_usuario ADD FOREIGN KEY
(idFactura) REFERENCES factura(idFactura);

ALTER TABLE compras_periodo_usuario ADD FOREIGN KEY
(Nrotarjeta) REFERENCES tarjeta(Nrotarjeta);

----------------------------------------------------------------------------------------




