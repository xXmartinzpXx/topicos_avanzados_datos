--ejercicio 4.1


SQL> set serveroutput on;
SQL> declare
n_bias NUMBER;
numero_invalido EXCEPTION;
begin
select precio into n_bias from Productos where productoid =2;
if n_bias <= 1600 then
Raise numero_invalido;
END if;
dbms_output.put_line('precio del producto: ' || n_bias);
exception
when numero_invalido then
dbms_output.put_line('Error: el precio es menor que el designado');
when no_data_found then
dbms_output.put_line('error: producto no encontrado');
end;
/  2    3    4    5    6    7    8    9   10   11   12   13   14   15   16
Error: el precio es menor que el designado

PL/SQL procedure successfully completed.

--ejercicio 4.2

SET SERVEROUTPUT ON;

DECLARE
    v_id_cliente   NUMBER := 1;
    v_nombre       VARCHAR2(50) := 'Pedro Ramirez';
    v_ciudad       VARCHAR2(50) := 'Coquimbo';
    v_fecha        DATE := TO_DATE('05-06-1990','DD-MM-YYYY');
BEGIN

    INSERT INTO clientes (clienteid, nombre, ciudad, fechanacimiento)
    VALUES (v_id_cliente, v_nombre, v_ciudad, v_fecha);

    DBMS_OUTPUT.PUT_LINE('Inserción realizada.');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: ID duplicado, no se puede insertar.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/