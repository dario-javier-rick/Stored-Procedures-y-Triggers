-- Motor: PostgreSQL 9.5.2

----------------------------------------------------------------------------------------
-- Consulta: Invocación de test:

select test();

----------------------------------------------------------------------------------------
-- Consulta: Invocación del facturador:

select facturador(18,'2015-11-01 12:00:00'::timestamp::date);

----------------------------------------------------------------------------------------
-- Consulta: Obtener a partir de una factura:
		-- Nombre y apellido
		-- Dirección
		-- Nro tarjeta
		-- Periodo de la factura
		-- Fecha de vencimiento
		-- Total a pagar

		
SELECT		c.Nombre,
		c.Apellido,
		c.domicilio,
		t.Nrotarjeta,
		f.Periodo,
		f.FechaVencimiento,
		SUM(tmp.valores) AS Total_a_pagar
FROM 		
		factura f, 
		cliente c,
		compras_periodo_usuario comp,
		tarjeta t,
		(
		SELECT  c.monto AS valores
		FROM    consumos c,
			compras_periodo_usuario comp
		WHERE   comp.nrooperacion = c.nroOperacion
		AND 	comp.idFactura = 32 -- INGRESAR UN ID DE FACTURA
		) tmp
WHERE 		
		f.Nrocliente = c.Nrocliente
AND		comp.Nrotarjeta = t.Nrotarjeta
AND		t.Nrocliente = f.Nrocliente
AND 		f.idFactura = 32 -- INGRESAR UN ID DE FACTURA
GROUP BY 	
		c.Nombre,
		c.Apellido,
		c.domicilio,
		t.Nrotarjeta,
		f.Periodo,
		f.FechaVencimiento;


----------------------------------------------------------------------------------------
-- Consulta: Obtener a partir de una factura:
		-- Todas las Compras del periodo

SELECT 
	con.nrooperacion,
	con.nrotarjeta,
	con.nrocomercio,
	con.fecha,
	con.monto,
	con.pagado
FROM	consumos con,
	compras_periodo_usuario cpu
WHERE 
	cpu.nrooperacion = con.nrooperacion
AND	cpu.idfactura = 32; -- INGRESAR UN ID DE FACTURA

----------------------------------------------------------------------------------------
-- Consulta: Obtener consumos sospechosos:

SELECT	c.nrooperacion,
		c.nroTarjeta,
		c.nroComercio,
		c.fecha,
		c.monto,
		c.pagado
FROM 	consumos c,
		(SELECT nroOperacion 
		FROM alertas a
		WHERE a.esRechazo = FALSE) a
WHERE 	a.NroOperacion = c.NroOperacion;
