--Martin Zepeda Puelles

--PARTE 1

--Pregunta 1
/*Relación Muchos a Muchos (10 pts): Explica qué es una relación muchos a muchos y 
cómo se implementa en una base de datos relacional. Usa un ejemplo basado en las 
tablas del esquema creado para la prueba.*/

--Respuesta 1
/*Una reación muchos a muchos es una relación entre dos entidades que conectan tienen una realcion mayor a uno 
osea por ejemplo un estudiante que tiene muchos profes y un profe que tiene muchos estudainets eso seria una muchos a muchos
y en base a eso se debe crear una base intermediaria donde se almacene las primari key de cada una de las tablas.Un ejemplo 
que se puede ver en la prueba es la de los agentes con los incidentes ya que uno o mas agentes pueden estar designados a uno
o mas accidentes*/

--Pregunta 2
/*Vistas (10 pts): Describe qué es una vista y cómo la usarías para mostrar el total de horas 
dedicadas por incidente, incluyendo la descripción del incidente y su severidad. Escribe la consulta SQL 
para crear la vista (no es necesario ejecutarla).*/

--Respuesta 2
/*Una vista es una cosulta que se guarda con un nombre y se puede usar como si fuera una tabla, 
es una forma de simplificar consultas complejas o de mostrar solo una parte de los datos a los usuarios.Aqui en una
vista para lo que seria creando una vista tanto con la tabla incidentes con la de asignacion para realizar una vista 
y lograr obtener el total de horas dedicadas por incidente, incluyendo la descripción del incidente y su severidad.

CREATE OR REPLACE VIEW VistaHorasIncidentes AS 
SELECT i.IncidenteID ,i.Descripcion, i.Severidad, SUM(a.Horas) AS horas_totales
FROM Incidentes i
JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
GROUP BY i.IncidenteID, i.Descripcion, i.Severidad;
*/

--Pregunta 3
/*Excepciones Predefinidas (10 pts): ¿Qué es una excepción predefinida en PL/SQL y cómo se maneja? 
Da un ejemplo de cómo manejarías la excepción NO_DATA_FOUND en un bloque PL/SQL.*/

--Respuesta 3
/*una excepción predefinida en PL/SQL es un error que ya está definido por el sistema y 
que se puede manejar en un bloque de código para evitar que el programa se detenga abruptamente.un caso en el 
que se puede manejar una excepcion NO_DATA_FOUND es cuando se busca un dato en una consulta y no se logra obtener nada,
para esto se coloca y que asi el programa no se cierra abruptamente*/

--Pregunta 4
/*Cursores Explícitos (10 pts): Explica qué es un cursor explícito y cómo se usa en PL/SQL. 
Menciona al menos dos atributos de cursor (como %NOTFOUND) y su propósito.*/

--Respuesta 4
/*Un crusor explicito es una herramienta que ayuda a recorrer una lista de resultados de una consulta, 
se declara y se abre para luego recorrerlo con un bucle y asi obtener los datos que se necesitan.Dos atributos de cursor 
son %NOTFOUND que se usa para verificar si el cursor no encontró ningún registro y %ROWCOUNT que se usa para 
contar el número de filas procesadas por el cursor.*/

--Parte 2

--pregunta 1
/*Escribe un bloque PL/SQL con un cursor explícito que liste las especialidades de agentes cuyo promedio de horas asignadas 
a incidentes sea mayor a 30, mostrando la especialidad y el promedio de horas. Usa un JOIN entre Agentes y Asignaciones.*/

Declare
    CURSOR c_agentes_especialidades IS
        SELECT a.Especialidad, AVG(asig.Horas) AS PromedioHoras
        FROM Agentes a
        JOIN Asignaciones asig ON a.AgenteID = asig.AgenteID
        GROUP BY a.Especialidad
        HAVING AVG(asig.Horas) > 30;
BEGIN
    FOR agente IN c_agentes_especialidades LOOP
        DBMS_OUTPUT.PUT_LINE('Especialidad: ' || agente.Especialidad || ', Promedio de Horas: ' || agente.PromedioHoras);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al ejecutar el bloque PL/SQL: ' || SQLERRM);
END;
/

--Pregunta 2
/*Escribe un bloque PL/SQL con un cursor explícito que aumente en 10 las horas de todas las asignaciones asociadas a 
incidentes con severidad 'Critical'. Usa FOR UPDATE y maneja excepciones.*/

DECLARE 
    CURSOR c_asignaciones_criticas IS
        SELECT a.Horas
        FROM Asignaciones a
        JOIN Incidentes i ON a.IncidenteID = i.IncidenteID
        WHERE i.Severidad = 'Critical'
        FOR UPDATE;
BEGIN
    FOR asignacion IN c_asignaciones_criticas LOOP
        UPDATE Asignaciones
        SET Horas = Horas + 10
        WHERE CURRENT OF c_asignaciones_criticas;
    END LOOP;
    close c_asignaciones_criticas;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al actualizar las asignaciones: ' || SQLERRM);
END;
/
--Pregunta 3 
/*Tipo de Objeto (20 pts) Crea un tipo de objeto incidente_obj con atributos incidente_id, descripcion, y 
un método get_reporte. Luego, crea una tabla basada en ese tipo y transfiere los datos de Incidentes a esa tabla. 
Finalmente, escribe un cursor explícito que liste la información de los incidentes usando el método get_reporte.*/

Declare
    TYPE incidente_obj IS OBJECT (
        incidente_id NUMBER,
        descripcion VARCHAR2(255),
        MEMBER FUNCTION get_reporte RETURN VARCHAR2
    );
    
    TYPE incidente_table IS TABLE OF incidente_obj;
    
    v_incidentes incidente_table;
    
    CURSOR c_incidentes IS
        SELECT IncidenteID, Descripcion
        FROM Incidentes;
BEGIN
    OPEN c_incidentes;
    LOOP
        FETCH c_incidentes INTO v_incidentes;
        EXIT WHEN c_incidentes%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Incidente ID: ' || v_incidentes.incidente_id || ', Descripción: ' || v_incidentes.descripcion);
    END LOOP;
    CLOSE c_incidentes;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al listar los incidentes: ' || SQLERRM);
END;
/




