/*Crea un procedimiento modificar_valores_productos que reciba un porcentaje de incremento
(parámetro IN) y aplique el aumento solo a productos
cuyo valor promedio por orden (calculado con una función) sea mayor a 500.
Usa un cursor para iterar sobre los productos.*/

CREATE OR REPLACE FUNCTION calcular_promedio_producto(p_ProductoID INT) RETURN NUMBER IS
    v_promedio NUMBER;
BEGIN
    SELECT AVG(P.Total / D.Cantidad) INTO v_promedio
    FROM DetallesPedidos D
    JOIN Pedidos P ON D.PedidoID = P.PedidoID
    WHERE D.ProductoID = p_ProductoID;

    RETURN v_promedio;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0; -- Si el producto no tiene pedidos, retorna 0
END;
/

CREATE OR REPLACE PROCEDURE modificar_valores_productos(p_porcentaje_incremento IN NUMBER) IS
    CURSOR cur_productos IS
        SELECT ProductoID
        FROM Productos;

    v_ProductoID INT;
    v_promedio NUMBER;
BEGIN
    OPEN cur_productos;

    LOOP
        FETCH cur_productos INTO v_ProductoID;
        EXIT WHEN cur_productos%NOTFOUND;

        -- Calcular promedio del producto por orden
        v_promedio := calcular_promedio_producto(v_ProductoID);

        -- Si el promedio supera 500, aplicar incremento
        IF v_promedio > 500 THEN
            UPDATE Productos
            SET Precio = Precio * (1 + p_porcentaje_incremento / 100)
            WHERE ProductoID = v_ProductoID;
        END IF;
    END LOOP;

    CLOSE cur_productos;
END;
/