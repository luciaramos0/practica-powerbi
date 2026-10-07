# Conectividad y transformación de datos en Power BI

Preparación de un set de ventas (`VENTAS_EXPORT`, archivo `.xlsx`) para el análisis, usando Power Query.

## 1. Carga del archivo

Se importan los datos desde un archivo Excel (.xlsx) y se verifica la vista previa antes de confirmar la carga.


![Conector de Excel](image1.png)

![Vista previa de los datos](image2.png)


## 2. Transformaciones aplicadas y orden

Panel "Pasos aplicados" de la consulta principal:


![Pasos aplicados - consulta principal](image3.png)


Orden de las transformaciones:

1. **Renombrar columnas**: primero, para trabajar el resto de los pasos con nombres legibles.
2. **Corregir tipos de datos**.
3. **Limpiar nulos y duplicados**.
4. **Normalizar la estructura**: separar Clientes y Transacciones, al final, cuando los datos ya están limpios.

### 2.1 Renombrar columnas

Se reemplazaron los nombres técnicos por nombres descriptivos en snake_case y en español:

| Original | Nuevo |
|---|---|
| COP_OP | id_venta |
| COD_CLI | id_cliente |
| NOM_CLI | nombre_cliente |
| MAIL_CLI | mail_cliente |
| TEL_CLI | tel_cliente |
| CIU_CLI | ciudad_cliente |
| PROV_CLI | provincia_cliente |
| SEG_CLI | segmento_cliente |
| FLG_ACT | cliente_activo |
| F_ALTA_CLI | fecha_alta |
| F_VTA | fecha_venta |
| COD_PROD | id_producto |
| DESC_PROD | descripcion_producto |
| RUBRO_PROD | categoria |
| CANT | cantidad |
| PU_VTA | precio_unitario |
| DTO_PCT | descuento |
| TOT_VTA | total_venta |
| COD_MON | moneda |
| CANAL_VTA | canal_venta |


![Renombrado de columnas (1)](image4.png)

![Renombrado de columnas (2)](image5.png)

![Renombrado de columnas (3)](image6.png)

![Renombrado de columnas (4)](image7.png)

![Renombrado de columnas (5)](image8.png)


## 3. Tipos de datos elegidos

| Columna | Tipo | Por qué |
|---|---|---|
| id_producto | Texto | Es un código identificador, no se usa para operar matemáticamente, así que no tiene sentido que figure como número. |
| descuento | Porcentaje | Representa un porcentaje; en formato porcentaje se lee directamente (por ejemplo 10 %) y se usa en el cálculo `1 - descuento`. |
| Resto de las columnas | Se mantuvo el tipo detectado | Power Query ya las había identificado correctamente (fechas como Fecha, montos como número, etc.). |


![id_producto: de número a texto](image9.png)

![descuento: a porcentaje](image10.png)


## 4. Valores nulos y duplicados

### 4.1 Nulos

**`id_venta` (clave primaria):** se eliminaron las filas nulas o vacías, porque sin identificador de venta no aportan ninguna información.


![Filas sin id_venta eliminadas](image11.png)


**`mail_cliente`:** los nulos se reemplazaron por `N/D` (no disponible). Se conserva la fila de la venta y el dato faltante queda explícito.


![Reemplazo de nulos en mail_cliente (1)](image12.png)

![Reemplazo de nulos en mail_cliente (2)](image13.png)


**`tel_cliente`:** mismo criterio, nulos reemplazados por `N/D`.


![Reemplazo de nulos en tel_cliente (1)](image14.png)

![Reemplazo de nulos en tel_cliente (2)](image15.png)


**`descuento`:** los nulos se reemplazaron por `0`, ya que en esas filas no se aplicaba descuento y se mantenía el precio original.


![Reemplazo de nulos en descuento (1)](image16.png)

![Reemplazo de nulos en descuento (2)](image17.png)


**`total_venta`:** tenía muchos nulos. Primero se reemplazaron por `0` y luego ese `0` se sustituyó por la fórmula:

```
each [cantidad] * [precio_unitario] * (1 - [descuento])
```

Así el total se recalcula para todas las filas faltantes de una sola vez, sin completarlas una por una. (Se hizo después de limpiar `descuento` para que la fórmula no falle por valores nulos.)


![Recuperación de total_venta (1)](image18.png)

![Recuperación de total_venta (2)](image19.png)

![Recuperación de total_venta (3)](image20.png)


### 4.2 Duplicados

La tabla `VENTAS_EXPORT` tiene una fila por venta, por lo que los datos del cliente se repiten en cada compra. Al separar la tabla de clientes, esas repeticiones generaban filas duplicadas (la tabla tenía 945 filas con el mismo cliente varias veces).

Se aplicó **Quitar duplicados** sobre `id_cliente` en la tabla `Clientes`, de modo que cada cliente aparezca una sola vez y `id_cliente` pueda funcionar como clave primaria. La tabla pasó de 945 filas a **___ filas** (clientes únicos).

![Quitar duplicados en Clientes](image25.png)

![Tabla Clientes sin duplicados](image26.png)

## 5. Separación de Clientes y Transacciones

**Procedimiento:**

1. Se duplicó la consulta principal.
2. En la copia se seleccionaron las columnas que describen al cliente y se quitaron las demás (*Quitar otras columnas*).
3. Se renombró la consulta como `Clientes`.


![Duplicar la consulta](image21.png)

![Selección de columnas de cliente](image22.png)

![Tabla Clientes resultante (1)](image23.png)

![Tabla Clientes resultante (2)](image24.png)


**Criterio:** los datos que describen a la persona y no cambian de una compra a otra van a **Clientes** (`id_cliente`, `nombre_cliente`, `mail_cliente`, `tel_cliente`, `ciudad_cliente`, `provincia_cliente`, `segmento_cliente`, `cliente_activo`, `fecha_alta`). Los datos propios de cada operación van a **Transacciones** (`id_venta`, `fecha_venta`, `id_producto`, `descripcion_producto`, `categoria`, `cantidad`, `precio_unitario`, `descuento`, `total_venta`, `moneda`, `canal_venta`).

La columna `id_cliente` es la **clave** que relaciona ambas tablas: clave primaria en Clientes y clave foránea en Transacciones.

### Tabla Transacciones

Para crear `Transacciones` se duplicó la consulta principal y se quitaron las columnas que describen al cliente, **conservando `id_cliente`** para poder relacionar ambas tablas.

![Pasos aplicados - Transacciones](image27.png)

![Tabla Transacciones resultante](image28.png)
