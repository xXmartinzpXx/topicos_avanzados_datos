5.1-----

SET SERVEROUTPUT ON;

DECLARE
    CURSOR c_clientes IS
        SELECT nombre, fechanacimiento
        FROM clientes
        ORDER BY fechanacimiento;
BEGIN
    FOR reg IN c_clientes LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || reg.nombre || ' - Nacimiento: ' || reg.fechanacimiento);
    END LOOP;
END;
/

5.2------

SET SERVEROUTPUT ON;

DECLARE
    CURSOR precio_producto_cursor IS
    	SELECT ProductoID, Precio
    	FROM Productos
    	FOR UPDATE;
    v_id NUMBER;
    v_precio NUMBER;

BEGIN
    OPEN precio_producto_cursor;
    FETCH precio_producto_cursor INTO v_id, v_precio;
    IF precio_producto_cursor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Precio original: ' || v_precio);
        v_precio := v_precio * 1.10; -- Aumentar un 10%
        UPDATE Productos SET Precio = v_precio WHERE CURRENT OF precio_producto_cursor;
        DBMS_OUTPUT.PUT_LINE('Precio actualizado: ' || v_precio);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Producto no encontrado.');
    END IF;
    CLOSE precio_producto_cursor;
END;
/