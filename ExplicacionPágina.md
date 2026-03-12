# Qué se ve en cada parte de la página de SchemaSpy

Este documento explica con detalle cada sección del reporte generado por SchemaSpy para una base de datos. Es útil para navegar y entender la estructura y documentación del modelo físico.

---

## Barra de navegación superior

- **Tables**: Muestra todas las tablas, vistas y comentarios.
- **Columns**: Detalla todas las columnas de las tablas y vistas.
- **Constraints**: Lista todas las restricciones (llaves foráneas, checks).
- **Relationships**: Presenta diagramas visuales de relaciones entre tablas.
- **Orphan Tables**: Muestra tablas que no tienen relaciones (huérfanas).
- **Anomalies**: Señala posibles problemas o anomalías en el modelo.
- **Routines**: Lista funciones, procedimientos y triggers programados.

---

## Tables (Página principal)

- **Panel de resumen**  
  - Tables: Número total de tablas.
  - Views: Número de vistas.
  - Columns: Total de columnas.
  - Constraints: Total de restricciones (FK, Unique, etc.).
  - Anomalies: Número de anomalías detectadas.
  - Routines: Total de procedimientos/funciones.

- **Database Properties**  
  - Información técnica de la base (tipo, versión).

- **Tabla de tablas/views**  
  - Table/View: Nombre de objeto (tabla o vista).
  - Children: Cuántas tablas dependen de esta como padre.
  - Parents: De cuántas tablas depende.
  - Columns: Cantidad de columnas.
  - Rows: Cantidad de registros.
  - Type: Si es tabla o vista.
  - Comments: Comentarios asociados.

- **Botones de exportación y búsqueda**  
  - Permiten filtrar, buscar y exportar información.

---

## Columns

- Muestra todas las columnas de todas las tablas y vistas.
- Table: Tabla a la que pertenece la columna.
- Type: Si es columna de tabla o vista.
- Column: Nombre de la columna.
- Tipo: Tipo de dato (NUMBER, VARCHAR2, DATE, etc).
- Size: Tamaño o precisión.
- Nullable: Si puede tener nulos.
- Auto: Si es autoincremental.
- Default: Valor por defecto.
- Comments: Comentario sobre la columna.

*Perfecto para comparar definiciones, buscar atributos clave, auditar tipos de datos.*

---

## Constraints

- **Foreign Key Constraints**
  - Constraint Name: Nombre de la restricción (generalmente FK).
  - Child Column: Columna de la tabla hija (referencia).
  - Parent Column: Columna de la tabla padre (referenciada).
  - Delete Rule: Qué sucede al borrar el padre (Restrict, Cascade).

- **Check Constraints**
  - Table: Tabla con la restricción.
  - Constraint Name: Nombre de la constraint.
  - Constraint: La regla de validación de datos.

*Permite analizar reglas de integridad y relaciones entre tablas. Puedes buscar y ordenar.*

---

## Relationships

- **Compact Relationships**  
  - Diagrama simple con cajas por tabla y líneas que unen relaciones clave (FK).
- **Large Relationships**  
  - Diagrama detallado con nombres de columnas, más información.

*Facilitan el análisis visual de la conectividad del modelo, mostrando relaciones padre-hijo y cardinalidad.*

---

## Orphan Tables

- Muestra **tablas huérfanas**: aquellas que no tienen ninguna relación (ni llaves foráneas entrantes ni salientes).
- Si la sección está vacía ("0 Orphan Tables"), significa que todas tus tablas están conectadas, lo que normalmente indica un buen diseño relacional.

*Sirve para identificar tablas auxiliares, errores de diseño, o entidades desenganchadas.*

---

## Anomalies

- Detecta y lista posibles **anomalías** en el modelo, como:
  - **Columnas cuyo nombre y tipo sugieren relación pero no hay FK declarada**
  - **Tablas sin índices**: pueden afectar desempeño
  - **Tablas que sólo tienen una columna**
  - **Tablas con columnas incrementales**: posible denormalización (mala práctica en diseño)
  - **Columnas cuyo valor por defecto es 'NULL' o 'null'**

- Cada tipo de anomalía tiene su propio bloque. Si dice "Anomaly not detected", está todo correcto respecto a ese criterio.

*Te ayuda a identificar problemas de diseño o mejoras posibles.*

---

## Routines

- Lista objetos programables: **funciones**, **procedimientos** y **triggers**.
- Name: Nombre del objeto.
- Type: Tipo (Function/Procedure/Trigger).
- Language: Lenguaje de implementación (PL/SQL, etc.).
- Deterministic: Si el resultado de la rutina es siempre el mismo para los mismos parámetros.
- Return Type: Tipo de dato de retorno (para funciones).
- Security Restriction: Restricciones de seguridad (si existen).
- Comments: Comentario asociado.

*Si está vacío ("No data available in table"), significa que tu esquema no tiene este tipo de objetos.*

---

## Resumen de utilidad de cada sección

- **Tables**: Visualiza la estructura principal y cantidad de entidades.
- **Columns**: Permitirá explicar detalladamente los atributos, tipos y reglas de cada campo.
- **Constraints**: Reglas clave de integridad y validaciones.
- **Relationships**: Explicación visual de la conectividad y lógica de negocio.
- **Orphan Tables**: Revisión de potenciales errores o tablas auxiliares.
- **Anomalies**: Auditoría de calidad y diseño técnico.
- **Routines**: Consulta de lógica programada/accesorios de automatización.


