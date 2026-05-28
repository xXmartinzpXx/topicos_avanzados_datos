--Martín Zepeda Puelles 
--Prueba 2: Topicos Avanzados de Bases de Datos


--Parte 1:

--Pregunta 1: 
/*Explica la diferencia entre un procedimiento almacenado y una función almacenada en PL/SQL. 
Da un ejemplo de cuándo usarías cada uno en el contexto de la base de datos de la prueba.*/

--Respuesta 1: 
/*Un procedimiento almacenado es un bloque de código PL/SQL que realiza una tarea específica y
 puede aceptar parámetros de entrada (IN), salida (OUT) o ambos (IN OUT). No devuelve un valor directamente, 
 sino que puede modificar los parámetros de salida o realizar acciones como insertar, 
 actualizar o eliminar datos en la base de datos. Por ejemplo, usaría un procedimiento almacenado para registrar una nueva asignación en la tabla Asignaciones, 
 ya que implica insertar datos y posiblemente actualizar el estado del incidente.*/

--Pregunta2:
/*Describe cómo usarías un parámetro IN OUT en un procedimiento almacenado. 
Escribe un ejemplo de un procedimiento que use un parámetro IN OUT para actualizar y devolver las horas de una asignación después de un ajuste.*/

--Respuesta 2: 
/*Un parámetro IN OUT en un procedimiento almacenado se utiliza cuando uno desea pasar un valor al procedimiento, permitir que el procedimiento
modifique ese valor, y luego devolver el valor modificado al llamador. Por ejemplo, si queremos ajustar las horas asignadas a un agente para un incidente específico, podríamos usar un parámetro
IN OUT para recibir las horas actuales, permitir que el valor sea ajustado dentro del procedimiento, y luego devolver el nuevo valor de horas al llamador. Aquí hay un ejemplo de cómo se podría implementar esto:*/ 

--Pregunta 3:
/*¿Cómo se puede usar una función almacenada dentro de una consulta SQL? 
Escribe un ejemplo de una función que calcule el total de horas asignadas a un incidente y úsala en una consulta para listar los incidentes con su total de horas.*/

--Respuesta 3: 
/*Una función almacenada en PL/SQL puede ser utilizada dentro de una consulta SQL siempre que la función esté diseñada para devolver un valor escalar (un solo valor).
Para calcular el total de horas asignadas a un incidente, se podría crear una función que sume las horas de todas las asignaciones relacionadas con un incidente específico.Luego,
esta función se puede usar en una consulta para listar los incidentes junto con el total de horas asignadas a cada uno. 
Ejemplo: 
CREATE OR REPLACE FUNCTION calcular_horas_incidente (
    p_IncidenteID IN NUMBER
) RETURN NUMBER AS
    v_TotalHoras NUMBER;
BEGIN
    SELECT SUM(Horas) INTO v_TotalHoras
    FROM Asignaciones
    WHERE IncidenteID = p_IncidenteID;

    RETURN NVL(v_TotalHoras, 0); -- Retorna 0 si no hay asignaciones
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al calcular horas: ' || SQLERRM);
        RETURN 0;
END;
-- Y ahora con esta función, podemos realizar la siguiente consulta para listar los incidentes con su total de horas asignadas:
SELECT 
    IncidenteID, 
    Descripcion, 
    calcular_horas_incidente(IncidenteID) AS TotalHoras 
FROM Incidentes;*/


--Pregunta 4:
/*Explica qué es un trigger y menciona dos tipos de eventos que pueden dispararlo. 
Da un ejemplo de un trigger que se dispare después de insertar una asignación en la tabla Asignaciones y actualice el estado 
del incidente a 'En Proceso' si estaba en 'Abierto'.*/

--Respuesta 4: 
/*Un trigger es un bloque de código PL/SQL que se ejecuta automáticamente en respuesta a alguna acción específica en la base de datos,
como una inserción, actualización o eliminación de datos. Los triggers pueden ser definidos para ejecutarse antes o después de la acción que los dispara.
Dos tipos de eventos que pueden disparar un trigger pueden ser:
1. AFTER INSERT: Se ejecuta después de que se ha insertado un nuevo registro en una tabla.
2. BEFORE UPDATE: Se ejecuta antes de que se actualice un registro en una tabla.
Ejemplo de trigger:
CREATE OR REPLACE TRIGGER actualizar_estado_incidente
AFTER INSERT ON Asignaciones
FOR EACH ROW
DECLARE
    v_EstadoIncidente Incidentes.Estado%TYPE;
    BEGIN
    -- Obtener el estado actual del incidente relacionado con la nueva asignación
    SELECT Estado INTO v_EstadoIncidente
    FROM Incidentes
    WHERE IncidenteID = :NEW.IncidenteID;
    -- Si el estado del incidente es 'Abierto', actualizarlo a 'En Proceso'
    IF v_EstadoIncidente = 'Abierto' THEN
        UPDATE Incidentes
        SET Estado = 'En Proceso'
        WHERE IncidenteID = :NEW.IncidenteID;
    END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró el incidente para la asignación insertada.');
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al actualizar el estado del incidente: ' || SQLERRM);
        END;
        */


--Parte 2:

--Ejercicio 1: 
/*Escribe un procedimiento registrar_asignacion que reciba un AgenteID, IncidenteID, Horas y Rol (parámetros IN). El procedimiento debe:
Insertar una nueva asignación en la tabla Asignaciones (usa el próximo AsignacionID disponible).
Actualizar el estado del incidente a 'En Proceso' si estaba en 'Abierto'.
Manejar excepciones si el agente o incidente no existen, o si el agente ya está asignado a ese incidente.*/

-- Respuesta Ejercicio 1:
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_AgenteID IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas IN NUMBER,
    p_Rol IN VARCHAR2(30)
) AS
    v_AsignacionID NUMBER;
    v_EstadoIncidente Incidentes.Estado%TYPE;
    Begin
    -- Verificar si el agente existe
    SELECT COUNT(*) INTO v_AsignacionID
    FROM Agentes
    WHERE AgenteID = p_AgenteID;
    IF v_AsignacionID = 0 THEN 
        RAISE_APPLICATION_ERROR(-20001, 'El agente no existe.');
        END IF;
    -- Verificar si el incidente existe
    SELECT COUNT(*) INTO v_AsignacionID
    FROM Incidentes 
    WHERE IncidenteID = p_IncidenteID;
    IF v_AsignacionID = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El incidente no existe.');
        END IF;
    -- Verificar si el agente ya está asignado al incidente
    SELECT COUNT(*) INTO v_AsignacionID
    FROM Asignaciones
    WHERE AgenteID = p_AgenteID AND IncidenteID = p_IncidenteID;
    IF v_AsignacionID > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El agente ya está asignado a este incidente.');
        END IF;
    -- Obtener el próximo AsignacionID disponible
    SELECT NVL(MAX(AsignacionID), 0) + 1 INTO v_AsignacionID
    FROM Asignaciones;
    -- Insertar la nueva asignación
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (v_AsignacionID, p_AgenteID, p_IncidenteID, p_Horas, p_Rol);
    -- Actualizar el estado del incidente a 'En Proceso' si estaba en 'Abierto'
    SELECT Estado INTO v_EstadoIncidente
    FROM Incidentes 
    WHERE IncidenteID = p_IncidenteID;
    IF v_EstadoIncidente = 'Abierto' THEN
        UPDATE Incidentes
        SET Estado = 'En Proceso'
        WHERE IncidenteID = p_IncidenteID;
        END IF;
        COMMIT;
        EXCEPTION
        WHEN OTHER THEN 
        DBMS_OUTPUT.PUT_LINE('Error al registrar la asignación: ' || SQLERRM);
        ROLLBACK;
        END;


--Ejercicio 2: 
/*Escribe una función calcular_horas_agente que reciba un AgenteID (parámetro IN) y devuelva el total de horas asignadas a ese agente en todos los incidentes.
 Luego, usa la función en un procedimiento mostrar_carga_agentes que muestre el total de horas por agente para todos los agentes, indicando su nombre y especialidad.*/

 --Respuesta Ejercicio 2:
 CREATE OR REPLACE FUNCTION calcular_horas_agente (
    p_AgenteID IN NUMBER
 ) RETURN NUMBER AS
    v_TotalHoras NUMBER;
    BEGIN
    SELECT NVL(SUM(Horas), 0) INTO v_TotalHoras
    FROM Asignaciones
    WHERE AgenteID = p_AgenteID;
    RETURN v_TotalHoras;
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al calcular horas para el agente ' || p_AgenteID || ': ' || SQLERRM);
        RETURN NULL;
        END;

CREATE OR REPLACE PROCEDURE mostrar_carga_agentes AS
BEGIN
    FOR rec IN (SELECT AgenteID, Nombre, Especialidad FROM Agentes) LOOP
        DECLARE
            v_HorasTotales NUMBER;
        BEGIN
            v_HorasTotales := calcular_horas_agente(rec.AgenteID);
            DBMS_OUTPUT.PUT_LINE('Agente: ' || rec.Nombre || ' | Especialidad: ' || rec.Especialidad || ' | Total Horas Asignadas: ' || v_HorasTotales);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error al mostrar carga para el agente ' || rec.AgenteID || ': ' || SQLERRM);
        END;
    END LOOP;
    EXCEPTION
    WHEN OTHER THEN
        DBMS_OUTPUT.PUT_LINE('Error al mostrar carga de agentes: ' || SQLERRM);
END;

 --Ejercicio 3:
 /*Implementa un sistema de auditoría manual usando un trigger. Para esto, primero crea una tabla llamada AuditoriaAsignaciones con las columnas necesarias. Luego, crea un trigger 
 auditar_asignaciones que se dispare después de insertar o eliminar una asignación en la tabla Asignaciones. 
 El trigger debe registrar en la tabla de auditoría el AsignacionID, AgenteID, IncidenteID, Horas, la acción realizada ('INSERT' o 'DELETE') y la fecha del registro.*/

 -- Respuesta Ejercicio 3:
 CREATE TABLE AuditoriaAsignaciones (
    AuditoriaID NUMBER PRIMARY KEY,
    AsignacionID NUMBER,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Accion VARCHAR2(10),
    FechaRegistro DATE
);

CREATE OR REPLACE TRIGGER auditar_asignaciones
AFTER INSERT OR DELETE ON Asignaciones
FOR EACH ROW
DECLARE
    v_Accion VARCHAR2(10);
BEGIN
    IF INSERTING THEN
        v_Accion := 'INSERT';
        INSERT INTO AuditoriaAsignaciones (AuditoriaID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
        VALUES (AuditoriaAsignaciones_seq.NEXTVAL, :NEW.AsignacionID, :NEW.AgenteID, :NEW.IncidenteID, :NEW.Horas, v_Accion, SYSDATE);
    ELSIF DELETING THEN
        v_Accion := 'DELETE';
        INSERT INTO AuditoriaAsignaciones (AuditoriaID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
        VALUES (AuditoriaAsignaciones_seq.NEXTVAL, :OLD.AsignacionID, :OLD.AgenteID, :OLD.IncidenteID, :OLD.Horas, v_Accion, SYSDATE);
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en trigger de auditoría: ' || SQLERRM);
END;

