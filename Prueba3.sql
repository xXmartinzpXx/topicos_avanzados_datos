/* Martin Zepeda Puelles*/





-----------Parte 1------------

--PREGUNTA 1 (10 puntos)
/*Explica qué es una transacción en una base de datos y describe las propiedades
ACID. Luego, muestra a través de un ejemplo cómo usarías múltiples savepoints
para manejar errores parciales en un procedimiento que asigna un agente a un
incidente y actualiza simultáneamente el estado del incidente. ¿Qué ocurre si
falla solo la actualización del estado?*/

--Respuesta 1: 
/*Una transacción en una base de datos es una unidad de trabajo que se ejecuta de manera atómica, consistente, aislada y duradera (ACID). Las propiedades ACID son:
- Atomicidad: Garantiza que todas las operaciones dentro de una transacción se completen exitosamente o ninguna se aplique.
- Consistencia: Asegura que la base de datos pase de un estado válido a otro estado válido después de la transacción.
- Aislamiento: Garantiza que las operaciones de una transacción no interfieran con las de otras transacciones concurrentes.
- Durabilidad: Asegura que los cambios realizados por una transacción confirmada se mantengan incluso en caso de fallos del sistema.
Un ejemplo pequeño de cómo usar múltiples savepoints en un procedimiento podría ser el siguiente:

CREATE OR REPLACE PROCEDURE asignar_agente_incidente(
    p_id_incidente NUMBER,
    p_id_agente NUMBER
) AS
BEGIN
    SAVEPOINT sp_inicio;

    INSERT INTO asignaciones_incidente(id_incidente, id_agente, fecha_asignacion)
    VALUES (p_id_incidente, p_id_agente, SYSDATE);

    SAVEPOINT sp_estado;

    UPDATE incidentes
    SET estado = 'ASIGNADO'
    WHERE id_incidente = p_id_incidente;

    -- Simulación de error en la actualización de estado
    IF p_id_incidente = 999 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Error al actualizar estado del incidente');
    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20010 THEN
            ROLLBACK TO sp_estado;
            DBMS_OUTPUT.PUT_LINE('Se mantuvo la asignación, pero no se modificó el estado del incidente.');
            COMMIT;
        ELSE
            ROLLBACK TO sp_inicio;
            DBMS_OUTPUT.PUT_LINE('Fallo general. Se deshace toda la operación.');
            RAISE;
        END IF;
END;
/

Y lo que podria ocurrir si falla la actualización de estado es que la transacción se revertirá al savepoint sp1, 
lo que significa que la asignación del agente al incidente se mantendrá, pero el estado del incidente no se actualizará. 
Esto permite manejar errores parciales sin perder toda la transacción.*/

--PREGUNTA 2 (10 puntos)
/*¿Qué es un Data Warehouse y cómo se diferencia de una base de datos
transaccional? Describe cómo diseñarías un modelo dimensional (tabla de hechos
y al menos dos dimensiones) para analizar las horas trabajadas por agente y
por severidad de incidente. ¿Qué ventajas tiene este modelo para consultas
analíticas versus consultar directamente las tablas transaccionales?*/

--Respuesta 2: 
/*Un Data Warehouse es un sistema de almacenamiento de datos diseñado para la consulta y el análisis de grandes volúmenes de información, mientras que una base de 
datos transaccional está optimizada para la gestión de operaciones diarias y transacciones en tiempo real. La principal diferencia radica en su propósito: el Data Warehouse
se centra en el análisi y la toma de decisiones, mientras que la base de datos transaccional se centra en la eficiencia y consistencia de las operaciones.
Un modelo dimensional para analizar las horas trabajadas por agente y por severidad de incidentes podría consistir en una tabla de hechos llamada "HorasTrabajadas" 
que contenga las columnas: AgenteID, SeveridadID, FechaID y Horas. Las dimensiones podrían ser:
1. DimAgente: con atributos como AgenteID, Nombre, Departamento.
2. DimSeveridad: con atributos como SeveridadID, NivelSeveridad.
Este modelo permite realizar consultas analíticas más eficientes, ya que las tablas de hechos y dimensiones están diseñadas para optimizar la agregación y el filtrado de datos,
lo que facilita la obtención de información relevante para la toma de decisiones, en comparación con consultar directamente las tablas transaccionales, que pueden ser más complejas 
y menos eficientes para este tipo de análisis.*/

--PREGUNTA 3 (10 puntos)
/*Explica cómo se implementa la herencia en Oracle usando tipos de objetos.
Da un ejemplo de una jerarquía de dos niveles: Agente → AgenteEspecialista →
AgentePentester, donde cada nivel agrega atributos y sobreescribe un método
calcular_costo(). ¿Qué implicancias tiene declarar un tipo como NOT
INSTANTIABLE?*/

--Respuesta 3: 
/*En Oracle, la herencia se implementa mediante tipos de objetos, donde un tipo puede heredar atributos y métodos de otro tipo. 
Esto permite crear jerarquías de objetos que comparten características comunes y pueden extenderse con atributos y métodos adicionales.
Un ejemplo de una jerarquía de dos niveles podría ser el siguiente:
Un ejemplo de una jerarquía de dos niveles con Agente → AgenteEspecialista → AgentePentester con el método calcular_costo() podría ser:
-- Tipo base (abstracto)

CREATE OR REPLACE TYPE agente_t AS OBJECT (
    id NUMBER,
    nombre VARCHAR2(50),
    NOT INSTANTIABLE MEMBER FUNCTION calcular_costo RETURN NUMBER
) NOT INSTANTIABLE NOT FINAL;
/

-- Subtipo 1: agrega un atributo
CREATE OR REPLACE TYPE agente_especialista_t UNDER agente_t (
    especialidad VARCHAR2(50),
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY agente_especialista_t AS
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER IS
    BEGIN
        RETURN 1000 + 200;
    END;
END;
/

-- Subtipo 2: agrega otro atributo y vuelve a sobrescribir
CREATE OR REPLACE TYPE agente_pentester_t UNDER agente_especialista_t (
    nivel VARCHAR2(30),
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY agente_pentester_t AS
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER IS
    BEGIN
        RETURN 1500 + 300 + CASE
            WHEN nivel = 'AVANZADO' THEN 500
            ELSE 0
        END;
    END;
END;
/
Eso implica que al declarar un tipo como NOT INSTANTIABLE, no se pueden crear instancias de ese tipo directamente. 
Esto es útil para definir tipos base abstractos que solo sirven como plantilla para otros tipos que heredan de ellos, 
asegurando que solo se puedan crear instancias de los subtipos concretos que implementan los métodos y atributos necesarios.
*/

--PREGUNTA 4 (10 puntos)
/*Describe las ventajas y desventajas de usar índices y particiones en una base
de datos. ¿Cómo usarías un índice compuesto y una partición por rango para
mejorar el rendimiento de consultas en la tabla Incidentes filtradas por
Severidad y FechaDeteccion? Explica qué es el partition pruning y cómo
impacta en el plan de ejecución.*/

--Respuesta 4:
/* Las ventajas de usar indices incluyen la mejora del rendimiento de las consultas al permitir un acceso más rápido a los datos, mientras que las desventajas pueden incluir un mayor tiempo de inserción y 
actualización debido a la necesidad de mantener los índices. Las particiones permiten dividir una tabla grande en partes más pequeñas, Lo que puede mejorar el rendimiento de las consultas y facilitar la 
gestión de datos, pero también puede aumentar la complejidad de la administración de la base de datos. Yo usaría un índice compuesto en las columnas Severidad y FechaDeteccion para acelerar 
las consultas que filtran por estas columnas. Además, particionaría la tabla Incidentes por rango de FechaDeteccion para que las consultas que buscan incidentes en un rango de fechas específico 
solo tengan que escanear las particiones relevantes. El partition pruning es una técnica que permite al optimizador de consultas omitir particiones que no son necesarias para una consulta específica, 
lo que reduce la cantidad de datos que se deben escanear y mejora el rendimiento. 
*/

-----------Parte 2------------

--EJERCICIO 1 (20 puntos)
/*Escribe un procedimiento registrar_asignacion que reciba un AgenteID,
IncidenteID, Horas y Rol (parámetros IN). El procedimiento debe:
  a) Insertar una nueva asignación en Asignaciones (usa el próximo
     AsignacionID disponible).
  b) Validar que el agente no supere 100 horas totales asignadas en
     incidentes con Estado 'Abierto'.
  c) Validar que el incidente no tenga ya 3 o más agentes asignados.
  d) Usar savepoints independientes para cada validación, de modo que un
     fallo en una no deshaga operaciones previas válidas.
  e) Manejar todas las excepciones con mensajes descriptivos.*/

--Respuesta Ejercicio 1:
/*
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_AgenteID IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas IN NUMBER,
    p_Rol IN VARCHAR2
) AS
    v_total_horas NUMBER;
    v_total_agentes NUMBER;
    v_nuevo_id NUMBER;

    e_horas_excedidas EXCEPTION;
    e_incidente_lleno EXCEPTION;
BEGIN
    -- Obtener el siguiente ID disponible
    SELECT NVL(MAX(AsignacionID), 0) + 1
      INTO v_nuevo_id
      FROM Asignaciones;

    -- Insertar la asignación
    SAVEPOINT sp_insert;

    INSERT INTO Asignaciones (
        AsignacionID,
        AgenteID,
        IncidenteID,
        Horas,
        Rol,
        FechaAsignacion
    ) VALUES (
        v_nuevo_id,
        p_AgenteID,
        p_IncidenteID,
        p_Horas,
        p_Rol,
        SYSDATE
    );

    -- Validación 1: horas del agente en incidentes abiertos
    SAVEPOINT sp_validar_horas;

    SELECT NVL(SUM(a.Horas), 0)
      INTO v_total_horas
      FROM Asignaciones a
      JOIN Incidentes i
        ON i.IncidenteID = a.IncidenteID
     WHERE a.AgenteID = p_AgenteID
       AND i.Estado = 'Abierto';

    IF v_total_horas + p_Horas > 100 THEN
        ROLLBACK TO sp_validar_horas;
        RAISE e_horas_excedidas;
    END IF;

    -- Validación 2: cantidad de agentes por incidente
    SAVEPOINT sp_validar_agentes;

    SELECT COUNT(*)
      INTO v_total_agentes
      FROM Asignaciones
     WHERE IncidenteID = p_IncidenteID;

    IF v_total_agentes >= 3 THEN
        ROLLBACK TO sp_validar_agentes;
        RAISE e_incidente_lleno;
    END IF;

    COMMIT;

EXCEPTION
    WHEN e_horas_excedidas THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'El agente supera las 100 horas asignadas en incidentes abiertos.'
        );

    WHEN e_incidente_lleno THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'El incidente ya tiene 3 o más agentes asignados.'
        );

    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO sp_insert;
        RAISE_APPLICATION_ERROR(
            -20003,
            'No se encontró información necesaria para completar la asignación.'
        );

    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(
            -20099,
            'Error inesperado al registrar la asignación: ' || SQLERRM
        );
END;
/

*/
--EJERCICIO 2 (20 puntos)
/*Diseña las tablas Fact_Asignaciones, Dim_Agente y Dim_Incidente para un
Data Warehouse basado en la base de datos de la prueba. Luego, escribe una
consulta analítica sobre las tablas transaccionales que muestre, para cada
agente, el total de horas trabajadas y el número de incidentes atendidos,
ordenado de mayor a menor por total de horas.*/

--Respuesta Ejercicio 2:
/*
-- Eliminar tablas si existen
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Fact_Asignaciones CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Dim_Incidente CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Dim_Agente CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Dimensión Agente
CREATE TABLE Dim_Agente (
    AgenteKey      NUMBER PRIMARY KEY,
    AgenteID       NUMBER UNIQUE,
    Nombre         VARCHAR2(50),
    Especialidad   VARCHAR2(50),
    FechaIngreso   DATE
);

-- Dimensión Incidente
CREATE TABLE Dim_Incidente (
    IncidenteKey   NUMBER PRIMARY KEY,
    IncidenteID    NUMBER UNIQUE,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
);

-- Tabla de Hechos
CREATE TABLE Fact_Asignaciones (
    AsignacionID   NUMBER PRIMARY KEY,
    AgenteKey      NUMBER,
    IncidenteKey   NUMBER,
    Horas          NUMBER,
    Rol            VARCHAR2(30),
    CONSTRAINT fk_fact_agente
        FOREIGN KEY (AgenteKey) REFERENCES Dim_Agente(AgenteKey),
    CONSTRAINT fk_fact_incidente
        FOREIGN KEY (IncidenteKey) REFERENCES Dim_Incidente(IncidenteKey)
);

-- Poblar Dim_Agente
INSERT INTO Dim_Agente (AgenteKey, AgenteID, Nombre, Especialidad, FechaIngreso)
SELECT
    ROW_NUMBER() OVER (ORDER BY AgenteID),
    AgenteID,
    Nombre,
    Especialidad,
    FechaIngreso
FROM Agentes;

-- Poblar Dim_Incidente
INSERT INTO Dim_Incidente (IncidenteKey, IncidenteID, Descripcion, Severidad, Estado, FechaDeteccion)
SELECT
    ROW_NUMBER() OVER (ORDER BY IncidenteID),
    IncidenteID,
    Descripcion,
    Severidad,
    Estado,
    FechaDeteccion
FROM Incidentes;

-- Poblar Fact_Asignaciones
INSERT INTO Fact_Asignaciones (AsignacionID, AgenteKey, IncidenteKey, Horas, Rol)
SELECT
    a.AsignacionID,
    da.AgenteKey,
    di.IncidenteKey,
    a.Horas,
    a.Rol
FROM Asignaciones a
JOIN Dim_Agente da ON da.AgenteID = a.AgenteID
JOIN Dim_Incidente di ON di.IncidenteID = a.IncidenteID;

COMMIT;
*/

--EJERCICIO 3 (20 puntos)
/*Crea un índice compuesto en Incidentes para las columnas Severidad y
FechaDeteccion. Luego, crea la tabla Incidentes particionada por rango de
FechaDeteccion (trimestral para 2026). Escribe una consulta que muestre el
total de horas asignadas por incidente para incidentes 'Critical' detectados
en el primer trimestre de 2026. Finalmente, muestra el plan de ejecución
con EXPLAIN PLAN e indica qué ventaja aporta la partición para esta consulta.*/

--Respuesta Ejercicio 3:
/*
-- Eliminar la tabla particionada si ya existe
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Incidentes_Part CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Crear tabla Incidentes particionada por rango de FechaDeteccion
CREATE TABLE Incidentes_Part (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
)
PARTITION BY RANGE (FechaDeteccion) (
    PARTITION p_q1_2026 VALUES LESS THAN (TO_DATE('2026-04-01','YYYY-MM-DD')),
    PARTITION p_q2_2026 VALUES LESS THAN (TO_DATE('2026-07-01','YYYY-MM-DD')),
    PARTITION p_q3_2026 VALUES LESS THAN (TO_DATE('2026-10-01','YYYY-MM-DD')),
    PARTITION p_q4_2026 VALUES LESS THAN (TO_DATE('2027-01-01','YYYY-MM-DD')),
    PARTITION p_otros   VALUES LESS THAN (MAXVALUE)
);

-- Crear índice compuesto en Severidad y FechaDeteccion
CREATE INDEX idx_incidentes_sev_fecha
ON Incidentes_Part (Severidad, FechaDeteccion)
LOCAL;

-- Cargar datos desde la tabla Incidentes original
INSERT INTO Incidentes_Part (IncidenteID, Descripcion, Severidad, Estado, FechaDeteccion)
SELECT IncidenteID, Descripcion, Severidad, Estado, FechaDeteccion
FROM Incidentes;

COMMIT;

SELECT
    i.IncidenteID,
    i.Descripcion,
    SUM(a.Horas) AS TotalHorasAsignadas
FROM Incidentes_Part i
JOIN Asignaciones a
    ON a.IncidenteID = i.IncidenteID
WHERE i.Severidad = 'Critical'
  AND i.FechaDeteccion BETWEEN DATE '2026-01-01' AND DATE '2026-03-31'
GROUP BY
    i.IncidenteID,
    i.Descripcion
ORDER BY
    TotalHorasAsignadas DESC;

EXPLAIN PLAN FOR
SELECT
    i.IncidenteID,
    i.Descripcion,
    SUM(a.Horas) AS TotalHorasAsignadas
FROM Incidentes_Part i
JOIN Asignaciones a
    ON a.IncidenteID = i.IncidenteID
WHERE i.Severidad = 'Critical'
  AND i.FechaDeteccion BETWEEN DATE '2026-01-01' AND DATE '2026-03-31'
GROUP BY
    i.IncidenteID,
    i.Descripcion;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);
*/