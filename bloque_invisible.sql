SET SERVEROUTPUT ON;

DECLARE
    v_total_clientes NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total_clientes FROM clientes;

    IF v_total_clientes > 5 THEN
        DBMS_OUTPUT.PUT_LINE('Total clientes: ' || v_total_clientes || ' -> Nivel ALTO');
    ELSIF v_total_clientes >= 3 THEN
        DBMS_OUTPUT.PUT_LINE('Total clientes: ' || v_total_clientes || ' -> Nivel MEDIO');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Total clientes: ' || v_total_clientes || ' -> Nivel BAJO');
    END IF;

END;
/