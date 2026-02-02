# Manual de Usuario - Gestor de Impresión 3D

¡Bienvenido al **Gestor de Impresión 3D**! Esta aplicación ha sido diseñada para ayudarte a llevar un control detallado de tus ingresos, gastos y costos operativos relacionados con tu actividad de impresión 3D.

---

## 📋 Índice
1. [Introducción](#1-introducción)
2. [Panel de Control (Dashboard)](#2-panel-de-control)
3. [Gestión de Componentes](#3-gestión-de-componentes)
    - [Impresoras](#impresoras)
    - [Materiales](#materiales)
4. [Registro de Ventas](#4-registro-de-ventas)
5. [Registro de Gastos](#5-registro-de-gastos)
6. [Resumen Financiero](#6-resumen-financiero)

---

## 1. Introducción
El **Gestor de Impresión 3D** permite calcular de forma precisa la rentabilidad de tus trabajos. Al registrar tus impresoras y materiales, la aplicación puede ayudarte a determinar los costos de fabricación y así fijar precios de venta adecuados.

---

## 2. Panel de Control
Al abrir la aplicación, verás el **Panel de Control**. Este es el centro de operaciones donde puedes ver:
- **Ganancia Neta**: El resultado total (Ventas - Costos de material/energía - Gastos generales).
- **Tarjetas de Resumen**: Visualización rápida de ventas totales, costos operativos y gastos.
- **Transacciones Recientes**: Una lista de las últimas 3 ventas y gastos registrados.

En la esquina superior derecha y mediante botones flotantes, tienes accesos directos para:
- 🟢 **Registrar Venta** (Icono de etiqueta)
- 🔴 **Registrar Gasto** (Icono de dinero con tachado)

---

## 3. Gestión de Componentes
Para acceder a esta sección, utiliza el icono de **Componentes** en la barra de navegación inferior.

### Impresoras
Aquí puedes dar de alta tus máquinas:
- **Nombre y Modelo**: Identifica cada impresora.
- **Costo de Adquisición**: Para tener una referencia de tu inversión.
- **Consumo (Watts)**: Vital para el cálculo del costo energético por impresión.
- **Contador de Impresiones**: Para llevar un seguimiento del uso de la máquina.

### Materiales
Registra tus rollos de filamento u otros insumos:
- **Marca y Tipo**: (Ej: PLA, PETG, Resina).
- **Color**: Para una mejor identificación.
- **Peso (gramos)**: El peso inicial del carrete.
- **Costo**: El precio pagado por el material.

---

## 4. Registro de Ventas
Cuando realices un trabajo para un cliente, regístralo como venta. Al presionar el botón de venta, se abrirá un formulario donde podrás:
1. **Descripción**: Nombre del proyecto o cliente.
2. **Seleccionar Impresora**: Para calcular el desgaste y costo energético.
3. **Seleccionar Material**: Para calcular el costo del material usado.
4. **Parámetros del Trabajo**: Cantidad de gramos usados y tiempo de impresión.
5. **Precio de Venta**: Lo que cobrarás al cliente.

### ⚡ Automatización al registrar:
La aplicación no solo guarda el registro, sino que realiza acciones automáticas:
- **Cálculo de Costo Real**: Suma el costo del filamento usado y el consumo eléctrico estimado.
- **Gestión de Stock**: Descuenta automáticamente los gramos utilizados del material seleccionado.
- **Uso de Máquina**: Incrementa el contador de impresiones de la impresora utilizada.
- **Restauración**: Si eliminas una venta, el material se devuelve al inventario y el contador de la impresora se decrementa.

---

## 5. Registro de Gastos
Utiliza esta sección para gastos que no están ligados directamente a una impresión específica (ej: compra de herramientas, mantenimiento, reparaciones, suscripciones).
- **Categoría**: Clasifica el gasto (Mantenimiento, Herramientas, Otros).
- **Descripción**: Detalle del gasto.
- **Monto**: El valor pagado.

---

## 6. Resumen Financiero
En el Panel de Control, los colores te indicarán el estado de tu negocio:
- **Verde**: Tu balance es positivo (ganancias).
- **Rojo**: Tus gastos y costos superan tus ingresos (pérdidas).

Puedes pulsar en **"Ver todas"** en las secciones de ventas o gastos para ver el historial completo y eliminar registros si fuera necesario.

---

## 7. Consejos y Buenas Prácticas
- **Pesa tus bobinas vacías**: Para tener un control exacto del stock, resta el peso del carrete de plástico (suele estar entre 200g y 250g) al peso total si el fabricante no lo indica.
- **Registra los fallos**: Si una impresión falla a mitad de camino, regístrala como una venta de 0€ pero con los gramos consumidos para que el stock de material siga siendo real.
- **Margen de error**: Utiliza el campo "Otros Costos" en el registro de ventas para añadir un pequeño porcentaje de amortización por mantenimiento o posibles fallos futuros.

---

## 8. Preguntas Frecuentes
**¿Cómo se calcula el costo de electricidad?**
Aplicamos la fórmula: `(Vatios de la impresora / 1000) * Horas de impresión * Precio del KWh`.

**¿Dónde se guardan mis datos?**
Los datos se guardan localmente en tu dispositivo. La aplicación no envía tus datos financieros a ningún servidor externo por razones de privacidad.

**¿Qué pasa si borro una venta por error?**
No te preocupes. Al borrarla, la aplicación automáticamente devuelve los gramos de filamento al inventario y resta 1 al contador de la impresora.

---
*Manual generado automáticamente para la aplicación Gestor Impresión 3D - 2024*
