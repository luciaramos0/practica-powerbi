# Conectividad y transformación de datos en Power BI

Preparación de un set de ventas (`VENTAS_EXPORT`, archivo `.xlsx`) para el análisis, usando Power Query.

## 1. Carga del archivo

Se importan los datos desde un archivo Excel (.xlsx) y se verifica la vista previa antes de confirmar la carga.


![Conector de Excel](img/image1.png)

![Vista previa de los datos](img/image2.png)


## 2. Transformaciones aplicadas y orden

Panel "Pasos aplicados" de la consulta principal:


![Pasos aplicados - consulta principal](img/image3.png)


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


![Renombrado de columnas (1)](img/image4.png)

![Renombrado de columnas (2)](img/image5.png)

![Renombrado de columnas (3)](img/image6.png)

![Renombrado de columnas (4)](img/image7.png)

![Renombrado de columnas (5)](img/image8.png)


## 3. Tipos de datos elegidos

| Columna | Tipo | Por qué |
|---|---|---|
| id_producto | Texto | Es un código identificador, no se usa para operar matemáticamente, así que no tiene sentido que figure como número. |
| descuento | Porcentaje | Representa un porcentaje; en formato porcentaje se lee directamente (por ejemplo 10 %) y se usa en el cálculo `1 - descuento`. |
| Resto de las columnas | Se mantuvo el tipo detectado | Power Query ya las había identificado correctamente (fechas como Fecha, montos como número, etc.). |


![id_producto: de número a texto](img/image9.png)

![descuento: a porcentaje](img/image10.png)


> ⚠️ **COMPLETAR (opcional):** nombrá el tipo de las demás columnas clave (`fecha_venta`, `fecha_alta`, `precio_unitario`, `total_venta`, `id_cliente`) y por qué lo mantuviste. Es lo que más suelen evaluar en este punto.

## 4. Valores nulos y duplicados

### 4.1 Nulos

**`id_venta` (clave primaria):** se eliminaron las filas nulas o vacías, porque sin identificador de venta no aportan ninguna información.


![Filas sin id_venta eliminadas](img/image11.png)


**`mail_cliente`:** los nulos se reemplazaron por `N/D` (no disponible). Se conserva la fila de la venta y el dato faltante queda explícito.


![Reemplazo de nulos en mail_cliente (1)](img/image12.png)

![Reemplazo de nulos en mail_cliente (2)](img/image13.png)


**`tel_cliente`:** mismo criterio, nulos reemplazados por `N/D`.


![Reemplazo de nulos en tel_cliente (1)](img/image14.png)

![Reemplazo de nulos en tel_cliente (2)](img/image15.png)


**`descuento`:** los nulos se reemplazaron por `0`, ya que en esas filas no se aplicaba descuento y se mantenía el precio original.


![Reemplazo de nulos en descuento (1)](img/image16.png)

![Reemplazo de nulos en descuento (2)](img/image17.png)


**`total_venta`:** tenía muchos nulos. Primero se reemplazaron por `0` y luego ese `0` se sustituyó por la fórmula:

```
each [cantidad] * [precio_unitario] * (1 - [descuento])
```

Así el total se recalcula para todas las filas faltantes de una sola vez, sin completarlas una por una. (Se hizo después de limpiar `descuento` para que la fórmula no falle por valores nulos.)


![Recuperación de total_venta (1)](img/image18.png)

![Recuperación de total_venta (2)](img/image19.png)

![Recuperación de total_venta (3)](img/image20.png)


### 4.2 Duplicados

> ⚠️ **COMPLETAR:** en las capturas no se ve un paso de *Quitar duplicados*. Indicá si buscaste filas duplicadas en `id_venta` y qué encontraste (cantidad), o aplicalo y explicá el resultado.
>
> **Importante:** la tabla Clientes quedó con 945 filas y con clientes repetidos (una fila por venta). Corresponde aplicar *Quitar duplicados* sobre `id_cliente` en esa tabla (ver sección 5).

## 5. Separación de Clientes y Transacciones

**Procedimiento:**

1. Se duplicó la consulta principal.
2. En la copia se seleccionaron las columnas que describen al cliente y se quitaron las demás (*Quitar otras columnas*).
3. Se renombró la consulta como `Clientes`.


![Duplicar la consulta](img/image21.png)

![Selección de columnas de cliente](img/image22.png)

![Tabla Clientes resultante (1)](img/image23.png)

![Tabla Clientes resultante (2)](img/image24.png)


**Criterio:** los datos que describen a la persona y no cambian de una compra a otra van a **Clientes** (`id_cliente`, `nombre_cliente`, `mail_cliente`, `tel_cliente`, `ciudad_cliente`, `provincia_cliente`, `segmento_cliente`, `cliente_activo`, `fecha_alta`). Los datos propios de cada operación van a **Transacciones** (`id_venta`, `fecha_venta`, `id_producto`, `descripcion_producto`, `categoria`, `cantidad`, `precio_unitario`, `descuento`, `total_venta`, `moneda`, `canal_venta`).

La columna `id_cliente` es la **clave** que relaciona ambas tablas: clave primaria en Clientes y clave foránea en Transacciones.

> ⚠️ **COMPLETAR:**
> - Aplicar *Quitar duplicados* sobre `id_cliente` en la tabla Clientes.
> - Crear la tabla **Transacciones** (en la consulta principal, quitar las columnas de cliente salvo `id_cliente`) y agregar su captura de "Pasos aplicados".
