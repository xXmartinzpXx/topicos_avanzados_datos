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
