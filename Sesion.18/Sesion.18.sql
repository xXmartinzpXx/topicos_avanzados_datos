--2
-- Especificación​

CREATE OR REPLACE PACKAGE gestion_clientes AS​

	e_edad_invalida EXCEPTION;​

	g_contador_clientes NUMBER := 0;​

	PROCEDURE registrar_cliente(​

    	p_cliente_id IN NUMBER,​

    	p_nombre IN VARCHAR2,​

    	p_ciudad IN VARCHAR2,​

    	p_fecha_nacimiento IN DATE​

	);​

	FUNCTION obtener_edad(​

    	p_cliente_id IN NUMBER​

	) RETURN NUMBER;​

END gestion_clientes;​

/​

-- Cuerpo​

CREATE OR REPLACE PACKAGE BODY gestion_clientes AS​

	PROCEDURE registrar_cliente(​

    	p_cliente_id IN NUMBER,​

    	p_nombre IN VARCHAR2,​

    	p_ciudad IN VARCHAR2,​

    	p_fecha_nacimiento IN DATE​

	) IS​

    	v_edad NUMBER;​

	BEGIN​

    	IF p_fecha_nacimiento >= SYSDATE THEN​

        	RAISE_APPLICATION_ERROR(-20001, 'La fecha de nacimiento debe ser anterior a la fecha actual.');​

    	END IF;​
   	 
    	v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, p_fecha_nacimiento) / 12);​

    	IF v_edad < 18 THEN​

        	RAISE e_edad_invalida;​

 	END IF;​
   	 
    	INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)​

    	VALUES (p_cliente_id, p_nombre, p_ciudad, p_fecha_nacimiento);​
   	 
    	g_contador_clientes := g_contador_clientes + 1;​

    	DBMS_OUTPUT.PUT_LINE('Cliente registrado. Total clientes: ' || g_contador_clientes);​

	EXCEPTION​

    	WHEN e_edad_invalida THEN​

        	DBMS_OUTPUT.PUT_LINE('Error: El cliente debe tener al menos 18 años.');​

        	RAISE;​

    	WHEN OTHERS THEN​

        	DBMS_OUTPUT.PUT_LINE('Error al registrar cliente: ' || SQLERRM);​

        	RAISE;​

	END registrar_cliente;​

	FUNCTION obtener_edad(​

    	p_cliente_id IN NUMBER​

	) RETURN NUMBER IS​

    	v_fecha_nacimiento DATE;​

    	v_edad NUMBER;​

	BEGIN​

    	SELECT FechaNacimiento INTO v_fecha_nacimiento​

    	FROM Clientes​

    	WHERE ClienteID = p_cliente_id;​
   	 
    	v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);​

    	RETURN v_edad;​

	EXCEPTION​

    	WHEN NO_DATA_FOUND THEN​

        	RAISE_APPLICATION_ERROR(-20002, 'Cliente no encontrado.');​

    	WHEN OTHERS THEN​

        	DBMS_OUTPUT.PUT_LINE('Error al calcular edad: ' || SQLERRM);​

        	RAISE;​

	END obtener_edad;​

END gestion_clientes;​

/​

-- Prueba con un cliente menor de edad​

EXEC gestion_clientes.registrar_cliente(9, 'Diego Rojas', 'Concepción', TO_DATE('2011-09-10', 'YYYY-MM-DD'));​