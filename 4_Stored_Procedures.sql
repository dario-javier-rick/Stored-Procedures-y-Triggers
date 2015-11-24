-- Stored procedure: funcion_alerta_consumos

-- Function: funcion_alerta_consumos(boolean, int)

--DROP CASCADE FUNCTION funcion_alerta_consumos();

CREATE OR REPLACE FUNCTION funcion_alerta_consumos() 
  RETURNS trigger AS
$BODY$
DECLARE

	--- Si una tarjeta registra 2 compras en un lapso menor de un minuto en
	--comercios distintos ubicados en el mismo código postal.
	unMinuto CURSOR
		FOR SELECT con.nrooperacion
		FROM consumos con,
			comercio com
		WHERE con.nrocomercio = com.nrocomercio
		AND con.fecha > CURRENT_TIMESTAMP - (1 * interval '1 minute')
		AND con.nrotarjeta = new.nrotarjeta
		AND con.nrocomercio <>  new.nrocomercio
		AND com.codigopostal = (SELECT codigopostal FROM comercio WHERE nrocomercio = new.nrocomercio);

	--- Si una tarjeta registra 2 compras en un lapso menor de 5 minutos en
	--comercios con diferentes códigos postales. 	
	cincoMinutos CURSOR
		FOR SELECT con.nrooperacion
		FROM consumos con,
			comercio com
		WHERE con.nrocomercio = com.nrocomercio
		AND con.fecha > CURRENT_TIMESTAMP - (5 * interval '1 minute')
		AND con.nrotarjeta = new.nrotarjeta
		AND com.codigopostal <> (SELECT codigopostal FROM comercio WHERE nrocomercio = new.nrocomercio);
		
	hayRegistros BOOLEAN;

	
BEGIN

	RAISE NOTICE 'Se invoca funcion_alerta_consumos()';

	hayRegistros := FALSE; 

	FOR recordvar IN unMinuto
	LOOP
		hayRegistros := TRUE; 
	END LOOP;

	FOR recordvar IN cincoMinutos
	LOOP	
		hayRegistros := TRUE; 
	END LOOP;	

	IF (hayRegistros = TRUE)
	THEN
		INSERT INTO alertas 
		VALUES 
		(
		DEFAULT, 
		new.NroOperacion,
		FALSE
		); 

		RAISE NOTICE 'Se inserta la alerta';
	END IF;

	RETURN NEW;

	EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE 'Ocurrió un error general en funcion_alerta_consumos';
	RETURN NULL;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION funcion_alerta_consumos() OWNER TO postgres;

----------------------------------------------------------------------------------------
-- Stored procedure: RECHAZO_COMPRA

-- Function: rechazo_compra(integer, character, integer, numeric)

-- DROP FUNCTION rechazo_compra(integer, character, integer, numeric);

CREATE OR REPLACE FUNCTION rechazo_compra(_idMotivo integer, nrotarjeta character, nrocomercio integer, monto numeric)
  RETURNS void AS
$BODY$
DECLARE
	vMotivo character (80);
	
BEGIN

	RAISE NOTICE 'Se invoca función rechazo_compra(%, %, %, %)', 
	_idMotivo, nrotarjeta, nrocomercio, monto;

	-- Obtengo el motivo del rechazo
	SELECT m.motivo
	INTO vMotivo
	FROM motivos_rechazo m
	WHERE m.idMotivo = _idMotivo;

	-- Inserto el rechazo en la tabla
	INSERT INTO rechazos 
	VALUES 
	(
	DEFAULT, 
	nrotarjeta,
	nrocomercio,
	CURRENT_TIMESTAMP,
	monto, 
	vMotivo
	); 
	
	-- Inserto la alerta correspondiente
	INSERT INTO alertas 
	VALUES 
	(
	DEFAULT, 
	currval('rechazos_NroRechazo_seq'),
	TRUE
	); 
		
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
 	    RAISE NOTICE 'Error en rechazo_compra. No se encontró el motivo del rechazo';
	WHEN OTHERS THEN
		RAISE NOTICE 'Ocurrió un error general en rechazo_compra';
		

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION rechazo_compra(integer, character, integer, numeric) OWNER TO postgres;

----------------------------------------------------------------------------------------
-- Stored procedure: AUTORIZACION_COMPRA

-- Function: autorizacion_compra(character, character, numeric, integer)

-- DROP FUNCTION autorizacion_compra(character, character, numeric, integer);

CREATE OR REPLACE FUNCTION autorizacion_compra(numtarjeta character, codseguridad character, montocompra numeric, numcomercio integer)
  RETURNS integer AS
$BODY$
DECLARE
	vNumTarjeta char(12);
	vCodSeguridad char(4);
	vEstado character(10);
	vLimiteCompra numeric(7,2);
	vValidahasta character(6);
	vMontoAdeudado decimal;

	vMes	char(2);
	vAño	char(6);
	vMesActual char(2);
	vAñoActual char(4);
	vAñoMesActual char(6);
BEGIN
	
	RAISE NOTICE 'Se invoca función autorizacion_compra(%, %, %, %)', 
	numtarjeta, codseguridad, montocompra, numcomercio;
	
	SELECT t.nrotarjeta, t.codseguridad, t.estado, t.limitecompra, t.validahasta
	INTO vNumTarjeta, vCodSeguridad, vEstado, vLimiteCompra, vValidahasta
	FROM tarjeta t
	WHERE numTarjeta = t.nrotarjeta;

	RAISE NOTICE 'vNumTarjeta = %',	vNumTarjeta;
	
	IF (vNumTarjeta IS NULL)
	THEN
	-- Tarjeta no existe
		RAISE NOTICE 'ENTRO EN CASO 1';
		PERFORM "rechazo_compra"
		(
		1, 
		numtarjeta,
		numcomercio, 
		montocompra
		);
		RETURN 0;
	END IF;

	IF (vCodSeguridad <> codSeguridad)
	THEN
	-- Codigo de seguridad invalido
		RAISE NOTICE 'vCodSeguridad = %, codSeguridad = %',	
		vCodSeguridad, codSeguridad;
		RAISE NOTICE 'ENTRO EN CASO 2';
		PERFORM "rechazo_compra"
		(
		2, 
		numtarjeta,
		numcomercio, 
		montocompra
		);
		RETURN 0;
	END IF;

	IF (vEstado <> 'Vigente')
	THEN
	-- Tarjeta suspendida o invalida
		RAISE NOTICE 'vEstado = %',	vEstado;
		RAISE NOTICE 'ENTRO EN CASO 3';
		PERFORM "rechazo_compra"
		(
		3, 
		numtarjeta,
		numcomercio, 
		montocompra
		);
		RETURN 0;
	END IF;

	
	vAñoActual := EXTRACT(YEAR FROM CURRENT_DATE);
	vMesActual := EXTRACT(MONTH FROM CURRENT_DATE);
	
	vAñoMesActual := vAñoActual || vMesActual;
	vMes := substring(vValidahasta from 1 for 2);
	vAño := substring(vValidahasta from 3 for 4);
	vValidahasta := vAño || vMes;
	
	RAISE NOTICE 'vAñoMesActual = %', vAñoMesActual;
	RAISE NOTICE 'vValidahasta = %', vValidahasta;

	IF (vValidahasta < vAñoMesActual)
	THEN
	-- Se me vencio la tarjeta
		RAISE NOTICE 'ENTRO EN CASO 4';
		PERFORM "rechazo_compra"
		(
		4, 
		numtarjeta,
		numcomercio, 
		montocompra
		);
		RETURN 0;
	END IF;

	vMontoAdeudado := (SELECT SUM(monto) FROM consumos
	WHERE vNumTarjeta=consumos.nrotarjeta
	AND consumos.Pagado <> 'S'); -- y si la tarjeta no tiene consumos?

	vMontoAdeudado := vMontoAdeudado + montoCompra;

	RAISE NOTICE 'vMontoAdeudado = %', vMontoAdeudado;
	RAISE NOTICE 'vLimiteCompra = %', vLimiteCompra;
	
	IF (vMontoAdeudado > vLimiteCompra)
	THEN
	-- Me excedo del límite de compra
		RAISE NOTICE 'ENTRO EN CASO 5';
		PERFORM "rechazo_compra"
		(
		5, 
		numtarjeta,
		numcomercio, 
		montocompra
		);
		RETURN 0;
	END IF;
	
	-- Si no caí en ninguno de los casos anteriores, 
	-- puedo realizar el consumo
	INSERT INTO consumos
	VALUES  
		(
		DEFAULT,
		numtarjeta,
		numcomercio,
		CURRENT_TIMESTAMP,
		montocompra,
		'N'
		);
	
	RETURN 1;

	EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE 'Ocurrió un error general en autorizacion_compra';
	RETURN 0;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION autorizacion_compra(character, character, numeric, integer) OWNER TO postgres;

----------------------------------------------------------------------------------------
-- Stored procedure: FACTURADOR

-- Function: facturador(integer, date)

-- DROP FUNCTION facturador(integer, date);

CREATE OR REPLACE FUNCTION facturador(_nrocliente integer, periodo date)
  RETURNS void AS
$BODY$
DECLARE
	
	-- Datos del cliente
	vNombre     char(40);
	vApellido   char(40);
	vDomicilio   char(60);
	tarjetas_cliente CURSOR FOR 
		SELECT nrotarjeta FROM tarjeta t
		WHERE t.nrocliente = _nrocliente;

	-- Datos de tarjeta
	vNroTarjeta  char(12);
	vTerminacion integer;
	vFechaInicio date;
	vFechaCierre date;
	vFechaVto date;
	
	consumos_tarjeta refcursor;

	vTotalConsumos INTEGER;
	vNroOperacion INTEGER;
BEGIN

	RAISE NOTICE 'Se invoca función facturador(%, %)', 
	_nrocliente, periodo;

	OPEN tarjetas_cliente;
	
	-- Traigo cada numero de tarjeta del cliente
	LOOP 
	FETCH tarjetas_cliente 
	INTO vNroTarjeta;
	
	IF NOT FOUND THEN
		EXIT;
	END IF;
	
		RAISE NOTICE '_nrocliente = %',	_nrocliente;
		RAISE NOTICE 'vNroTarjeta = %',	vNroTarjeta;

		-- Averiguo terminacion de tarjeta
		vTerminacion:= substring(vNroTarjeta from 12 for 1)::integer;
		
		RAISE NOTICE 'vTerminacion = %', vTerminacion;

		-- Averiguo fecha de inicio, cierre y vencimiento de la tarjeta
		SELECT c.fechainicio, c.fechacierre, c.fechavto 
		FROM cierres c
		INTO vFechaInicio, vFechaCierre, vFechaVto
		WHERE c.terminacion=vTerminacion 
		AND EXTRACT(MONTH FROM periodo) = c.mes
		AND EXTRACT(YEAR FROM periodo) = c.año; 

		RAISE NOTICE 'vFechaInicio = %', vFechaInicio;
		RAISE NOTICE 'vFechaCierre = %', vFechaCierre;
		RAISE NOTICE 'vFechaVto = %', vFechaVto;

		-- Inserto factura
		INSERT INTO factura
		VALUES  
		(
			DEFAULT,
			_nrocliente,
			periodo,
			vFechaVto
		);

		RAISE NOTICE 'Insertó la factura!';

		-- Busco los consumos correspondientes 
		OPEN consumos_tarjeta FOR 
		SELECT c.nrotarjeta, c.nrooperacion
		FROM consumos c
		WHERE c.nrotarjeta =  vNroTarjeta
		AND c.fecha BETWEEN vFechaInicio AND vFechaCierre;


		-- Recorro todos los consumos de esa factura
		-- y los inserto en compras_periodo_usuario
		LOOP 
		FETCH NEXT FROM consumos_tarjeta 
		INTO vNroTarjeta, vNroOperacion;
				
		IF NOT FOUND THEN
			EXIT;
		END IF;
			
		RAISE NOTICE 'Entró en loop compras_periodo_usuario!';
		
			INSERT INTO compras_periodo_usuario
			VALUES  
			(
				DEFAULT,
				currval('factura_idfactura_seq'), -- currVal de factura
				vNroTarjeta,
				vNroOperacion
			);
			
			RAISE NOTICE 'Insertó consumo!';

			-- Marco como pagado el consumo 
			UPDATE consumos
			SET Pagado = 'S'
			WHERE NroOperacion = vNroOperacion; 
			
			RAISE NOTICE 'Cambió estado de consumo!';
		
		END LOOP;

		CLOSE consumos_tarjeta;

	END LOOP;
	
	CLOSE tarjetas_cliente;

	EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE 'Ocurrió un error general en facturador';
	RETURN;


END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION facturador(integer, date) OWNER TO postgres;


----------------------------------------------------------------------------------------
-- Stored procedure: TEST

-- Function: test()

-- DROP FUNCTION test();

CREATE OR REPLACE FUNCTION test()
  RETURNS void AS
$BODY$
DECLARE

	consumos_virtuales CURSOR 
			FOR SELECT Nrotarjeta, Nrocomercio, Monto, Codseguridad 
			FROM TEST;
			
	
	vNroTarjeta CHARACTER(12);
	vNroComercio INTEGER;
	vMonto NUMERIC;
	vCodigoSeguridad CHARACTER(4);
BEGIN

	RAISE NOTICE 'Se invoca función test()';
	
	OPEN consumos_virtuales;
	LOOP 
	FETCH consumos_virtuales	
	INTO vNroTarjeta, vNroComercio, vMonto, vCodigoSeguridad;

	IF NOT FOUND THEN
		EXIT;
	END IF;
	
		PERFORM "autorizacion_compra"
		(
		vNroTarjeta,
		vCodigoSeguridad,
		vMonto, 
		vNroComercio
		);

	END LOOP;
	
	CLOSE consumos_virtuales;

	RETURN;

	EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE 'Ocurrió un error general en test';
	RETURN;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION test() OWNER TO postgres;

	
----------------------------------------------------------------------------------------
-- Trigger: ALERTAS

-- DROP TRIGGER alerta ON consumos;

CREATE TRIGGER alerta
    AFTER INSERT ON consumos -- Verifico si es una alerta después de insertar
    FOR EACH ROW
    EXECUTE PROCEDURE funcion_alerta_consumos();

----------------------------------------------------------------------------------------


