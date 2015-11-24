--------------------------------------------------------
DROP SEQUENCE alertas_idalerta_seq CASCADE;
DROP SEQUENCE compras_periodo_usuario_idcpu_seq CASCADE;
DROP SEQUENCE factura_idfactura_seq CASCADE;
DROP SEQUENCE motivos_rechazo_idmotivo_seq CASCADE;
---------------------DROP TABLES------------------------
DROP TABLE test;
DROP TABLE tarjeta CASCADE;
DROP TABLE rechazos;
DROP TABLE parametros;
DROP TABLE motivos_rechazo;
DROP TABLE factura CASCADE;
DROP TABLE consumos;
DROP TABLE compras_periodo_usuario;
DROP TABLE compras;
DROP TABLE comercio;
DROP TABLE cliente;
DROP TABLE cierres;
DROP TABLE alertas;
--------------------DROP TIPO DE DATO--------------------
DROP TYPE estados_tarjeta;
--------------------DROP FUNCTION----------------
DROP FUNCTION funcion_alerta_consumos() CASCADE;
DROP FUNCTION funcion_alerta_rechazo(boolean, int);
DROP FUNCTION rechazo_compra(integer, character, integer, numeric);
DROP FUNCTION autorizacion_compra(character, character, numeric, integer);
DROP FUNCTION facturador(integer, date);
DROP FUNCTION test();