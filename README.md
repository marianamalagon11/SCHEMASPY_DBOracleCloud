
# SchemaSpy para Oracle Autonomous Database
## 1. Objetivo
Este proyecto genera documentación técnica navegable del esquema de una base de datos Oracle Autonomous Database usando `SchemaSpy`.
El proceso está orientado a inspección estructural del modelo relacional. No crea registros de negocio, no modifica tablas y no ejecuta operaciones DML o DDL sobre la base de datos. Su función es leer metadatos y construir una salida HTML local.
El resultado final es un sitio estático en la carpeta `output/` con información sobre tablas, columnas, restricciones y relaciones.
---
## 2. Qué hace SchemaSpy
`SchemaSpy` es una herramienta de documentación de esquemas de bases de datos. Se conecta por JDBC, consulta el diccionario de datos del motor y genera páginas HTML con navegación entre objetos del esquema.
En este proyecto, SchemaSpy:
- se conecta a Oracle mediante `Oracle Thin Driver`;
- usa un `wallet` local para resolver la conexión segura a Autonomous Database;
- consulta metadatos del esquema `ADMIN`;
- detecta tablas, columnas, claves primarias, claves foráneas y restricciones;
- genera diagramas y páginas HTML de consulta.
SchemaSpy trabaja en modo lectura. Los datos que produce son artefactos de documentación, no datos transaccionales.
---
## 3. Componentes principales del proyecto
Los archivos más importantes son:
- `schemaspy-6.2.4.jar`: motor principal de generación.
- `ojdbc11-23.3.0.23.09.jar`: driver JDBC de Oracle.
- `schemaspy.properties`: configuración principal de ejecución.
- `oracle-atp.properties`: definición personalizada del tipo de conexión para Oracle Autonomous Database.
- `wallet/`: archivos de conexión segura de Oracle.
- `ejecutar.bat`: script principal para regenerar la documentación.
- `fix-relationships.ps1`: postproceso para completar la página de relaciones globales.
- `output/`: salida generada por SchemaSpy.
---
## 4. Conexión a Oracle Autonomous Database
### 4.1 Modelo de conexión
La conexión se hace usando un alias TNS del `wallet` y el driver JDBC de Oracle.
El archivo `oracle-atp.properties` define el patrón de conexión:
- `extends=ora`
- `connectionSpec=jdbc:oracle:thin:@<db>?TNS_ADMIN=C:/Users/maria/Downloads/SGBD/schemaspy/schemaspy/wallet`
Esto significa que SchemaSpy construye una URL JDBC Oracle Thin a partir de un alias del `tnsnames.ora` y resuelve el `wallet` desde la carpeta local del proyecto.
### 4.2 Wallet utilizado
La carpeta `wallet/` contiene los archivos necesarios para la conexión segura a Oracle Autonomous Database:
- `cwallet.sso`
- `ewallet.p12`
- `ewallet.pem`
- `keystore.jks`
- `truststore.jks`
- `tnsnames.ora`
- `sqlnet.ora`
- `ojdbc.properties`
- `README`
### 4.3 Alias TNS disponibles
En `wallet/tnsnames.ora` están definidos los servicios:
- `bases_high`
- `bases_medium`
- `bases_low`
- `bases_tp`
- `bases_tpurgent`
La configuración actual usa `bases_high`.
### 4.4 Archivo `sqlnet.ora`
El archivo `wallet/sqlnet.ora` fija la ubicación del wallet y la validación SSL:
- `WALLET_LOCATION = .../wallet`
- `SSL_SERVER_DN_MATCH=yes`
Esto permite que el driver Oracle localice los certificados y resuelva correctamente la conexión.
---
## 5. Configuración de `schemaspy.properties`
El archivo `schemaspy.properties` contiene la configuración efectiva de la ejecución.
Parámetros relevantes:
- `schemaspy.t`: apunta a `oracle-atp.properties`.
- `schemaspy.db=bases_high`: alias TNS que se va a documentar.
- `schemaspy.u=ADMIN`: usuario de conexión.
- `schemaspy.p=...`: contraseña del usuario.
- `schemaspy.s=ADMIN`: esquema analizado.
- `schemaspy.cat=%`: catálogo utilizado para evitar errores de deducción de catálogo en Oracle.
- `schemaspy.o=output`: carpeta de salida.
- `schemaspy.dp=...ojdbc11...jar`: ruta del driver JDBC.
- `schemaspy.gv=C:/Program Files/Graphviz`: ubicación de Graphviz.
- `oracle.net.tns_admin=.../wallet`: ruta del wallet local.
### Consideración de seguridad
Actualmente la contraseña está almacenada en texto plano en el archivo de configuración. Esto funciona para ejecución local, pero no es una práctica recomendada para entornos productivos o repositorios compartidos.
La alternativa recomendada es mover las credenciales a variables de entorno o a un archivo no versionado.
---
## 6. Flujo de generación
### 6.1 Script principal
El archivo `ejecutar.bat` automatiza el proceso completo:
1. entra a la carpeta del proyecto;
2. elimina la carpeta `output/` previa;
3. crea una nueva carpeta `output/`;
4. ejecuta `SchemaSpy` con `schemaspy.properties`;
5. ejecuta `fix-relationships.ps1`.
### 6.2 Por qué existe `fix-relationships.ps1`
Durante la ejecución se detectó que SchemaSpy generaba correctamente las páginas HTML principales, pero no completaba de forma consistente la página global de relaciones (`relationships.html`) en el resumen general.
El script `fix-relationships.ps1` resuelve este punto mediante postproceso:
- toma los archivos `.dot` de `output/diagrams/summary/`;
- genera los archivos `.png` y `.map` con Graphviz;
- reescribe `output/relationships.html` para insertar los diagramas globales con navegación por mapa HTML.
Con este paso adicional, la documentación final queda funcional.
---
## 7. Qué datos se generan y cómo se guardan
Es importante separar dos conceptos.
### 7.1 Datos que SchemaSpy consulta
SchemaSpy consulta metadatos del esquema, no datos de negocio. Entre ellos:
- definición de tablas;
- columnas y tipos de datos;
- claves primarias;
- claves foráneas;
- restricciones;
- dependencias entre tablas;
- información auxiliar del esquema.
### 7.2 Artefactos que el proyecto genera localmente
La salida se guarda en disco, dentro de `output/`, en forma de:
- páginas HTML;
- archivos JavaScript y CSS;
- diagramas `.dot`;
- diagramas renderizados `.png`;
- mapas HTML `.map`;
- archivos de orden de inserción y eliminación;
- XML del análisis.
### 7.3 Persistencia de la salida
La salida no se guarda dentro de la base de datos. Todo se escribe en el sistema de archivos local.
Cada ejecución del flujo principal regenera `output/` desde cero.
---
## 8. Contenido del directorio `output/`
La carpeta `output/` es el resultado final del proyecto.
Archivos y carpetas relevantes observados:
- `index.html`
- `columns.html`
- `constraints.html`
- `relationships.html`
- `orphans.html`
- `anomalies.html`
- `routines.html`
- `tables/`
- `diagrams/`
- `bases_high.ADMIN.xml`
- `insertionOrder.txt`
- `deletionOrder.txt`
- `images/`
- `fonts/`
- `bower/`
---
## 9. Qué se puede encontrar en la página generada
### 9.1 `Tables`
La página principal `index.html` muestra el inventario de tablas del esquema analizado.
En el estado actual del proyecto aparecen, entre otras:
- `ESTUDIANTE`
- `INSCRIPCION`
- `MATERIA`
- `SALON`
Cada tabla enlaza a una página propia dentro de `output/tables/`.
### 9.2 `Columns`
`columns.html` consolida todas las columnas del esquema y permite revisar:
- tabla;
- nombre de columna;
- tipo de dato;
- tamaño;
- nulabilidad;
- relaciones asociadas.
Es una vista transversal del diseño físico del esquema.
### 9.3 `Constraints`
`constraints.html` presenta las restricciones detectadas por SchemaSpy, incluyendo claves primarias y foráneas.
Sirve para ubicar nombres técnicos de restricciones y validar integridad referencial.
### 9.4 `Relationships`
`relationships.html` contiene los diagramas globales de relaciones del esquema.
La página muestra:
- una vista compacta;
- una vista ampliada.
Ambas vistas son navegables por imagen y enlazan a las tablas correspondientes.
### 9.5 `Orphan Tables`
`orphans.html` lista tablas sin relaciones de entrada ni salida.
Puede existir aunque no haya tablas huérfanas reales. En ese caso, la sección estará disponible, pero sin contenido significativo.
### 9.6 `Anomalies`
`anomalies.html` muestra condiciones estructurales potencialmente anómalas, por ejemplo:
- relaciones implícitas no declaradas formalmente;
- tablas sin índices;
- patrones que SchemaSpy considera dignos de revisión.
Si aparece `Anomaly not detected`, significa que ese criterio no identificó problemas en el esquema.
### 9.7 `Routines`
`routines.html` está destinado a rutinas como procedimientos y funciones almacenadas.
Si el esquema no expone rutinas o no fueron detectadas en el análisis actual, esta sección puede aparecer vacía. Ese comportamiento es esperable.
---
## 10. Detalle por tabla
Dentro de `output/tables/` se genera una página por cada tabla detectada.
Estas páginas contienen normalmente:
- nombre de la tabla;
- número estimado de filas;
- columnas;
- tipos de datos;
- claves primarias;
- relaciones padre-hijo;
- referencias a otras tablas.
Esto permite navegar desde la vista global hasta el detalle puntual de cada objeto.
---
## 11. Artefactos auxiliares generados
Además del HTML principal, el proyecto genera otros archivos técnicos útiles.
### 11.1 `bases_high.ADMIN.xml`
Es una representación estructurada del análisis en formato XML.
### 11.2 `insertionOrder.txt`
Define un orden lógico sugerido para inserción de datos respetando dependencias entre tablas.
### 11.3 `deletionOrder.txt`
Define un orden lógico sugerido para eliminación de datos respetando integridad referencial.
### 11.4 `diagrams/*.dot`
Archivos Graphviz DOT que describen los diagramas de relaciones.
### 11.5 `diagrams/*.png`
Representación visual renderizada de los archivos `.dot`.
### 11.6 `diagrams/*.map`
Mapas HTML usados para navegación interactiva sobre las imágenes de relaciones.
---
## 12. Comportamiento sobre la base de datos
Este proyecto no inserta, actualiza ni elimina información de negocio.
La secuencia funcional es:
1. autenticarse contra Oracle Autonomous Database;
2. resolver el alias TNS definido en el wallet;
3. consultar metadatos del esquema `ADMIN`;
4. generar documentación local en `output/`.
Su comportamiento es de lectura y documentación.
---
## 13. Requisitos operativos
Para ejecutar correctamente el proyecto se requiere:
- Java instalado y disponible en el sistema;
- Graphviz instalado en `C:\Program Files\Graphviz`;
- el driver JDBC de Oracle presente en la carpeta del proyecto;
- un wallet válido dentro de `wallet/`;
- credenciales correctas del usuario Oracle.
---
## 14. Limitaciones y observaciones
- La generación del resumen global de relaciones requiere postproceso adicional con `fix-relationships.ps1`.
- `Orphan Tables` y `Routines` pueden mostrarse vacíos si el esquema no contiene esos objetos o si no fueron detectados.
- Algunos warnings de Graphviz sobre tamaño de celdas pueden aparecer durante la renderización, pero no impiden la generación de la documentación.
- El proyecto está configurado actualmente para `bases_high`, pero el wallet contiene otros alias que podrían usarse si se modifica `schemaspy.db`.
---
## 15. Ejecución recomendada
La forma recomendada de regenerar la documentación es:
```bat
cd C:\Users\maria\Downloads\SGBD\schemaspy\schemaspy
.\ejecutar.bat
```
Ejecución manual equivalente:
```bat
cd C:\Users\maria\Downloads\SGBD\schemaspy\schemaspy
java -jar schemaspy-6.2.4.jar -configFile schemaspy.properties -gv "C:\Program Files\Graphviz"
powershell -ExecutionPolicy Bypass -File ".\fix-relationships.ps1"
```
---
## 16. Resultado esperado
Al finalizar una ejecución correcta deben existir, como mínimo:
- `output/index.html`
- `output/columns.html`
- `output/constraints.html`
- `output/relationships.html`
- `output/orphans.html`
- `output/anomalies.html`
- `output/routines.html`
- `output/tables/*.html`
- `output/diagrams/summary/*.png`
La página de entrada principal es:
- `output/index.html`
---
## 17. Resumen técnico final
Este proyecto implementa un pipeline local de documentación de esquema con las siguientes etapas:
1. conexión segura a Oracle Autonomous Database mediante `wallet`;
2. análisis del esquema `ADMIN` del servicio `bases_high`;
3. extracción de metadatos estructurales;
4. generación de HTML, XML y diagramas auxiliares;
5. postproceso de la página de relaciones para dejar la salida completa y navegable.
El resultado es una documentación técnica reproducible del esquema relacional, útil para análisis, soporte, revisión de integridad y comprensión de la estructura de la base de datos.
---
## 18. Versionado del proyecto en Git

Para preparar este proyecto como repositorio compartible se definieron las siguientes reglas:

- `schemaspy.properties` no debe versionarse porque contiene credenciales locales.
- `wallet/` no debe versionarse porque contiene material sensible de conexión de Oracle Autonomous Database.
- `output/` no se versiona porque es salida generada y puede reconstruirse.
- los archivos `*.log` no se versionan por ser artefactos transitorios de ejecución.

Para permitir que otra persona reconstruya el entorno sin acceder a credenciales reales, se incluye el archivo:

- `schemaspy.properties.example`

Ese archivo actúa como plantilla y debe copiarse a `schemaspy.properties` antes de ejecutar el proyecto en otra máquina.

### Publicación a un repositorio remoto

El proyecto puede inicializarse como repositorio local con Git y luego vincularse a un remoto en GitHub u otra plataforma.

Secuencia típica:

```bat
git init -b main
git add .
git commit -m "Initial commit: SchemaSpy Oracle Autonomous documentation project"
git remote add origin <URL_DEL_REPOSITORIO>
git push -u origin main
```
