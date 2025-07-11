# 📱 Ojo Ciudadano

**Ojo Ciudadano** es una aplicación móvil desarrollada en **Flutter**, cuyo propósito principal es facilitar a los **administradores municipales** la gestión eficiente de reportes ciudadanos sobre deficiencias en servicios públicos, así como la **asignación y seguimiento de tareas a técnicos responsables**.

---

## 🎯 Objetivo del Proyecto

Desarrollar una aplicación Flutter que permita a los **administradores**:

- Gestionar reportes creados por ciudadanos sobre problemas en la vía pública y servicios.
- Visualizar el estado de los casos y darles seguimiento.
- Asignar casos a técnicos especializados y monitorear su desempeño.
- Mejorar los tiempos de respuesta institucional y la atención ciudadana.

---

## 📝 Descripción del Proyecto

El proyecto consiste en una aplicación móvil enfocada en el uso del **administrador del sistema**, quien podrá revisar y gestionar los casos que han sido levantados por ciudadanos a través de otros canales (app ciudadana, web, etc.).

Cada caso incluye la siguiente información:

- Categoría del problema.
- Ubicación geográfica.
- Descripción del incidente.
- Evidencia visual (fotos o videos).
- Fecha y hora de registro.
- Nombre del ciudadano que lo reportó.

El administrador podrá asignar estos casos a técnicos, cambiar su estatus, visualizar su ubicación en mapa, y consultar métricas generales del sistema.

---

## 🗂️ Categorías Sugeridas

- Alumbrado  
- Bacheo  
- Recolección de basura  
- Tiraderos de agua  
- Vehículos abandonados o sucios  
- Exceso de ruido  
- Maltrato animal  
- Inseguridad  
- Señales de alto en mal estado  
- Semáforos en mal estado  
- Señalización deficiente  
- Temas de equidad de género  
- Atención a rampas para discapacitados  
- Inconformidades en trámites y servicios  
- Casos adicionales no previstos  

---

## 👤 Casos de Uso

### 📱 Aplicación para el Administrador

1. **Pantalla de inicio:**
   - Splash screen.
   - Pantalla de login con opción de registrar nuevos usuarios (altas).

2. **Onboarding:**
   - Introducción breve al sistema y su propósito.

3. **Navegación principal (menú inferior):**
   - **Home**
   - **Feed Evidencia**
   - **Mapa Interactivo**
   - **Reportes**
   - **Perfil**

4. **Home (Dashboard):**
   - Información general de los reportes:
     - Casos activos, atendidos, pendientes.
     - Tiempo promedio de resolución.
     - Reportes por categoría.

5. **Feed Evidencia (Estilo TikTok):**
   - Visualización vertical tipo feed con imágenes/videos de los reportes.
   - Navegación con swipe (arriba/abajo).
   - Barra inferior del caso con:
     - Estatus del reporte.
     - Categoría del caso.
     - Botón “ℹ️ Más info”.

6. **Detalles del Caso (Bottom Sheet o Popup):**
   - Información mostrada:
     - **ID del caso**
     - **Fecha y hora de registro**
     - **Descripción del problema**
     - **Categoría**
     - **Nombre del ciudadano que lo reportó**
     - **Evidencia (imagen/video)**
   - Acciones disponibles:
     - Asignar a técnico.
     - Cambiar estatus.
     - Visualizar ubicación en el mapa.

7. **Mapa Interactivo:**
   - Ubicación geográfica de los casos.
   - Filtros por categoría y estatus.
   - Acceso a detalles tocando un marcador.

8. **Gestión de Técnicos:**
   - Lista de técnicos disponibles.
   - Carga de trabajo actual y desempeño histórico.
   - Asignación individual o masiva de reportes.

9. **Perfil del Administrador:**
   - Cambiar avatar.
   - Modificar contraseña.
   - Elegir tema (claro u oscuro).

---

## ⚙️ Aspectos Técnicos

1. Aplicación desarrollada en **Flutter Mobile**.  
2. Arquitectura basada en el patrón **Clean Architecture**.  
3. Persistencia de datos a través de **Supabase**.  
4. Uso de **API REST** y herramientas de automatización como **n8n**, según las necesidades del flujo.  

---

## 🎨 Paleta de Colores

- Color Primario (Guinda): `#612232`  
- Color Secundario (Gris): `#d3d3d3`  
- Color de Fondo/Base (Blanco): `#FFFFFF`  
- Color para Botones de Acción (Dorado): `#bfb07e`  

---

## 🚧 Estado del Proyecto

> *Este documento representa la fase inicial de planeación del proyecto "Ojo Ciudadano". La funcionalidad principal estará orientada a los administradores que gestionan reportes de ciudadanos y coordinan el trabajo de los técnicos.*

## Credenciales para inicio de sesion DEMO
Email: admin@example.com
Contraseña: password