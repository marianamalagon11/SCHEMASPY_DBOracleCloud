# Sustentación de Base de Datos Oracle — Guía Completa

## Contenido
- Querys DML y DDL con ejemplos
- Explicación: ¿Afectan el esquema/SchemaSpy o no?
- Preguntas teóricas (incluyendo SchemaSpy)
- Tips para la presentación

---

## Tipos de Queries

### DML (Data Manipulation Language) — Operaciones con datos
No afectan el esquema/modelo físico. Solo modifican el contenido de las tablas, no la estructura. No se reflejan en SchemaSpy.

- SELECT — Consulta de datos
  ```sql
  SELECT * FROM ESTUDIANTE;
  SELECT NOMBRE, CORREO FROM ESTUDIANTE WHERE ID_ESTUDIANTE = 5;
  ```

- INSERT — Inserción de datos
  ```sql
  INSERT INTO ESTUDIANTE (ID_ESTUDIANTE, NOMBRE, CORREO)
  VALUES (31, 'Lucía Gómez', 'lucia.gomez@universidad.edu');
  ```

- UPDATE — Actualización de datos
  ```sql
  UPDATE ESTUDIANTE
  SET CORREO = 'lucia.gomez2024@universidad.edu'
  WHERE ID_ESTUDIANTE = 31;
  ```

- DELETE — Eliminación de datos
  ```sql
  DELETE FROM ESTUDIANTE
  WHERE ID_ESTUDIANTE = 31;
  ```

¿Por qué no afectan el esquema?  
Porque solo modifican las filas de la tabla. El modelo estructural (tablas, columnas, constraints, relaciones) sigue igual.

---

### DDL (Data Definition Language) — Estructura/modelo
Afectan el esquema/modelo físico. Cambian la definición de las tablas, columnas, constraints, relaciones, y sí se reflejan en SchemaSpy.

- CREATE TABLE — Creación de nueva tabla
  ```sql
  CREATE TABLE NOTAS (
    ID_NOTA NUMBER PRIMARY KEY,
    ID_ESTUDIANTE NUMBER REFERENCES ESTUDIANTE(ID_ESTUDIANTE),
    ID_MATERIA NUMBER REFERENCES MATERIA(ID_MATERIA),
    CALIFICACION NUMBER
  );
  ```
  ¿Afecta el esquema? Sí. Aparece una nueva tabla en el modelo-schema.

- ALTER TABLE — Agregar columna
  ```sql
  ALTER TABLE ESTUDIANTE ADD EDAD NUMBER;
  ```
  ¿Afecta el esquema? Sí. Aparece la columna EDAD en SchemaSpy.

- ALTER TABLE — Modificar columna
  ```sql
  ALTER TABLE ESTUDIANTE MODIFY NOMBRE VARCHAR2(100) NOT NULL;
  ```
  ¿Afecta el esquema? Sí. Cambia el tipo/tamaño/nulleabilidad de la columna.

- ALTER TABLE — Agregar llave foránea
  ```sql
  ALTER TABLE PAGOS
  ADD CONSTRAINT FK_PAGOS_ESTUDIANTE FOREIGN KEY (ID_ESTUDIANTE)
  REFERENCES ESTUDIANTE(ID_ESTUDIANTE);
  ```
  ¿Afecta el esquema? Sí. Se crea una relación (línea en Relationships).

- DROP TABLE — Eliminar tabla
  ```sql
  DROP TABLE NOTAS;
  ```
  ¿Afecta el esquema? Sí. Desaparece la tabla y sus relaciones.

- ADD CONSTRAINT UNIQUE
  ```sql
  ALTER TABLE ESTUDIANTE ADD CONSTRAINT UNQ_CORREO UNIQUE (CORREO);
  ```
  ¿Afecta el esquema? Sí. Aparece la constraint en el modelo.

- CREATE INDEX / DROP INDEX
  ```sql
  CREATE INDEX IDX_NOMBRE_ESTUDIANTE ON ESTUDIANTE(NOMBRE);
  DROP INDEX IDX_NOMBRE_ESTUDIANTE;
  ```
  ¿Afecta el esquema? A veces, depende del reporte. Es parte del modelo físico.

- ADD CHECK
  ```sql
  ALTER TABLE ESTUDIANTE ADD CONSTRAINT CHK_EDAD CHECK (EDAD >= 0);
  ```
  ¿Afecta el esquema? Sí. Aparece como constraint.

- Comentarios
  ```sql
  COMMENT ON TABLE ESTUDIANTE IS 'Tabla de estudiantes';
  COMMENT ON COLUMN ESTUDIANTE.EDAD IS 'Edad del estudiante';
  ```
  ¿Afecta el esquema? Sí. Aparece en la sección “comments” en el reporte si se soporta.

- Secuencia (IDs automáticos)
  ```sql
  CREATE SEQUENCE SEQ_ID_ESTUDIANTE START WITH 32 INCREMENT BY 1;
  ```
  ¿Afecta el esquema? Sí, aparece como objeto de base de datos.

---

### Vistas, triggers, funciones, procedimientos, secuencias
Se reflejan en el modelo si SchemaSpy los soporta.

- CREATE VIEW
  ```sql
  CREATE VIEW VISTA_ESTUDIANTES_MAYORES AS
  SELECT * FROM ESTUDIANTE WHERE EDAD > 18;
  ```
  ¿Afecta el esquema? Sí, como objeto “view”.

- CREATE TRIGGER
  ```sql
  CREATE OR REPLACE TRIGGER TRG_ESTUDIANTE_BEFORE_INSERT
  BEFORE INSERT ON ESTUDIANTE
  FOR EACH ROW
  BEGIN
    :NEW.CORREO := LOWER(:NEW.CORREO);
  END;
  ```
  ¿Afecta el esquema? Sí, como objeto “trigger”.

- CREATE FUNCTION
  ```sql
  CREATE OR REPLACE FUNCTION PROMEDIO_NOTAS(id_estudiante NUMBER)
  RETURN NUMBER IS
    prom NUMBER;
  BEGIN
    SELECT AVG(CALIFICACION) INTO prom FROM NOTAS WHERE ID_ESTUDIANTE = id_estudiante;
    RETURN prom;
  END;
  ```
  ¿Afecta el esquema? Sí, como objeto “routine/function”.

---

### Consultas JOIN (relaciones)
Demuestran relaciones funcionales entre tablas, pero NO afectan el esquema/modelo.

```sql
SELECT E.NOMBRE, M.NOMBRE AS MATERIA, I.FECHA
FROM ESTUDIANTE E
JOIN INSCRIPCION I ON E.ID_ESTUDIANTE = I.ID_ESTUDIANTE
JOIN MATERIA M ON I.ID_MATERIA = M.ID_MATERIA;
```

¿Afecta el esquema? No. Muestra relaciones de datos, útil para sustentar comprensión de modelo.

---

## Preguntas teóricas frecuentes

### Sobre bases de datos y queries
- ¿Qué es una llave primaria y por qué es importante?  
  Es un campo único que identifica cada fila sin repetir. Asegura la integridad y permite relaciones con otras tablas.

- ¿Qué hace una restricción UNIQUE, FOREIGN KEY, CHECK?  
  UNIQUE impide valores repetidos. FOREIGN KEY relaciona tablas y controla la integridad referencial. CHECK valida que los datos cumplan reglas determinadas.

- ¿Qué diferencia hay entre DML y DDL?  
  DML modifica datos (INSERT, UPDATE, DELETE). DDL modifica estructura/modelo (CREATE, ALTER, DROP).

- ¿Cómo evitar datos duplicados?  
  Usando PRIMARY KEY o UNIQUE en las columnas correspondientes.

- ¿Cómo evitar borrar estudiantes si tienen inscripciones asociadas?  
  Mediante FOREIGN KEY con restricción ON DELETE RESTRICT o NO ACTION.

- ¿Qué es una vista y para qué se usa?  
  Es un “query guardado” que simplifica accesos repetitivos o reportes.

- ¿Qué es una secuencia?  
  Objeto que genera valores únicos (muy útil para IDs automáticos).

- ¿Qué es un trigger?  
  Procedimiento automático que se dispara ante eventos (INSERT, UPDATE, DELETE).

- ¿Cómo consultar relaciones entre tablas?  
  Usando JOINs y revisando el diagrama generado por SchemaSpy.

### Sobre SchemaSpy
- ¿Qué es SchemaSpy y para qué sirve?  
  Es una herramienta que analiza la estructura de la base de datos y genera reportes visuales del modelo relacional (tablas, columnas, constraints, relaciones) en HTML para facilitar la documentación, auditoría y comprensión de la base.

- ¿Qué tipo de cambios aparecen reflejados en el reporte de SchemaSpy?  
  Todos los cambios estructurales (crear, modificar o eliminar tablas, columnas, constraints, relaciones, vistas, triggers, etc.). Los cambios de datos (DML) NO se reflejan.

- ¿Por qué es útil usar SchemaSpy en un proyecto académico o profesional?  
  Porque permite visualizar de manera clara y rápida el modelo físico, detectar anomalías, mostrar relaciones entre tablas y documentar la base automáticamente.

- ¿Qué secciones del reporte de SchemaSpy puedes mostrar/explicar?  
  Tablas y sus columnas/keys  
  Constraints  
  Relationships (diagramas de relaciones)  
  Anomalías y “orphan tables”  
  Comments y routines (si aplica)

- ¿Cómo se actualiza el reporte de SchemaSpy?  
  Debes ejecutar SchemaSpy cada vez que haya cambios estructurales en la base para que el reporte refleje el estado más reciente.

---

## Ejemplo de práctica

Crear tabla con relación:
```sql
CREATE TABLE PAGOS (
    ID_PAGO NUMBER PRIMARY KEY,
    ID_ESTUDIANTE NUMBER REFERENCES ESTUDIANTE(ID_ESTUDIANTE),
    MONTO NUMBER
);
```
Refleja relación en SchemaSpy, en el diagrama de relaciones.

Agregar constraint UNIQUE:
```sql
ALTER TABLE ESTUDIANTE ADD CONSTRAINT UNQ_CORREO UNIQUE (CORREO);
```
Aparece en Constraints del reporte.

Insertar dato:
```sql
INSERT INTO ESTUDIANTE (ID_ESTUDIANTE, NOMBRE, CORREO)
VALUES (32, 'Pedro Lopez', 'pedro.lopez@universidad.edu');
```
No cambia el modelo, pero muestra operatividad y acceso a datos.

---
