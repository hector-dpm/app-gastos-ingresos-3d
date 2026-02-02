# 📄 Documentación Técnica - Gestor de Impresión 3D

Este documento proporciona una visión detallada de la arquitectura, el diseño y la lógica de implementación de la aplicación **Gestor de Impresión 3D**.

---

## 🏗️ Arquitectura del Proyecto

La aplicación sigue el patrón de diseño **MVVM (Model-View-ViewModel)** adaptado al ecosistema de Flutter mediante el uso de **Providers** para la gestión del estado y **SQLite** para el almacenamiento persistente.

### Estructura de Carpetas

```text
lib/
├── db/            # Lógica de base de datos (SQLite)
├── models/        # Modelos de datos (clases Dart)
├── providers/     # Gestión de estado (ChangeNotifier)
├── screens/       # Interfaces de usuario (Vistas)
└── widgets/       # Componentes de UI reutilizables
```

---

## 🛠️ Stack Tecnológico

- **Framework:** Flutter 3.x
- **Lenguaje:** Dart
- **Base de Datos:** SQLite (`sqflite`)
- **Gestión de Estado:** `provider`
- **Utilidades:**
  - `intl`: Formateo de fechas y monedas.
  - `path`: Gestión de rutas de archivos.
  - `sqflite_common_ffi`: Soporte para bases de datos en plataformas de escritorio (Windows/macOS/Linux).

---

## 📊 Modelos de Datos

### 1. Printer (Impresora)
Representa el hardware físico.
- `id`: Autoincremental.
- `nombre`: Alias de la máquina.
- `modelo`: Modelo técnico.
- `costo`: Precio de adquisición.
- `consumo_watts`: Consumo energético medio (por defecto 300W).
- `contador_impresiones`: Número total de trabajos realizados.

### 2. Material (Material)
Representa los consumibles (filamento, resina, etc.).
- `id`: Autoincremental.
- `nombre`: Marca o nombre comercial.
- `tipo`: Material (PLA, PETG, etc.).
- `color`: Color del carrete.
- `peso_g`: Stock actual en gramos.
- `costo`: Precio del rollo completo.

### 3. Sale (Venta/Trabajo)
El eje central de la aplicación, donde se cruzan todos los datos.
- `id`: Identificador único.
- `descripcion`: Nombre del proyecto.
- `precio_venta`: Precio cobrado al cliente.
- `peso_usado_g`: Gramos consumidos en la pieza.
- `tiempo_impresion_h`: Duración del trabajo en horas.
- `costo_electricidad`: Calculado basado en horas y vatios.
- `otros_costos`: Fallos, post-procesado, etc.

---

## 💡 Lógica de Negocio y Cálculos

La aplicación automatiza el cálculo de rentabilidad mediante las siguientes fórmulas:

### Costo de Producción
$$C_{total} = (Gramos \times Costo_{G}) + (Tiempo_{H} \times Consumo_{KW} \times Precio_{KWh}) + Otros_{Costos}$$

### Ganancia Neta
$$Ganancia = Precio_{Venta} - Costo_{Total} - Gastos_{Generales}$$

### Automatización del Inventario
- Al registrar una **Venta**, se resta automáticamente el peso usado del `Material` seleccionado.
- Al registrar una **Venta**, se incrementa el `contador_impresiones` de la `Printer` utilizada.
- Si se **elimina** una venta, los cambios se revierten automáticamente (se devuelve el stock y se resta al contador).

---

## 🗄️ Gestión de Base de Datos

Se utiliza una base de datos local llamada `impresoras_materiales.db`.
- **Relaciones:** Se utilizan claves foráneas con `ON DELETE CASCADE` para mantener la integridad referencial entre impresoras/materiales y las ventas.
- **Migraciones:** El sistema de versiones de `DatabaseHelper` permite actualizaciones fluidas de la estructura de tablas sin pérdida de datos para el usuario.

---

## 🚀 Instalación y Desarrollo

1. **Requisitos:** Tener instalado Flutter SDK y Dart.
2. **Obtener dependencias:**
   ```bash
   flutter pub get
   ```
3. **Ejecutar en modo debug:**
   ```bash
   flutter run
   ```
4. **Build para Windows:**
   ```bash
   flutter build windows
   ```

---

*Desarrollado con ❤️ para la comunidad de impresión 3D.*
