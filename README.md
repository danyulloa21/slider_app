# slider_app

A Flutter application with Supabase integration for player score tracking.

## 🔧 Configuración de Variables de Entorno

Esta aplicación utiliza variables de entorno para gestionar configuraciones sensibles.

### Configuración Inicial

1. Copia el archivo de ejemplo `.env.example` a `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edita el archivo `.env` con tus credenciales reales:
   ```env
   # Supabase Configuration
   SUPABASE_URL=https://tu-proyecto.supabase.co
   SUPABASE_ANON_KEY=tu_anon_key_aqui
   
   # Authentication
   AUTH_EMAIL=tu_email@example.com
   AUTH_PASSWORD=tu_password_aqui
   ```

3. El archivo `.env` está en `.gitignore` y **NO debe** ser commiteado.

### Variables Disponibles

| Variable | Descripción |
|----------|-------------|
| `SUPABASE_URL` | URL de tu proyecto Supabase |
| `SUPABASE_ANON_KEY` | Clave anónima pública de Supabase |
| `AUTH_EMAIL` | Email para autenticación |
| `AUTH_PASSWORD` | Contraseña para autenticación |

## 🚀 Instalación y Ejecución

1. Instala las dependencias:
   ```bash
   flutter pub get
   ```

2. Configura tu archivo `.env` (ver arriba)

3. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

## 🏗️ Arquitectura

El proyecto sigue una arquitectura de servicios:

```
lib/
├── main.dart                    # Punto de entrada, carga .env
└── services/
    └── supabase_service.dart   # Lógica de Supabase centralizada
```

### SupabaseService

Todas las operaciones de Supabase están encapsuladas en `SupabaseService`:

- `signIn()` - Autenticación
- `insertPlayer()` - Insertar jugador
- `updatePlayer()` - Actualizar puntos
- `checkAndUpsertPlayer()` - Upsert inteligente
- `retrievePoints()` - Obtener puntos

## 🔒 Seguridad

- **Nunca** compartas tu archivo `.env`
- El archivo `.env` está en `.gitignore`
- Usa `.env.example` como plantilla

## 📦 Dependencias

- `supabase_flutter: ^2.10.3` - Cliente de Supabase
- `flutter_dotenv: ^5.1.0` - Gestión de variables de entorno

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:
    
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 🪪 Créditos

- [Flutter](https://flutter.dev) - Framework para construir aplicaciones nativas
- [Supabase](https://supabase.io) - Backend como servicio
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) - Gestión de variables de entorno
- [freepngimg](https://freepngimg.com/png/148675-car-top-vector-view-free-hd-image) - Iconos de autos utilizados en la aplicación
# slider_app

## 👥 Integrantes del Equipo  
- **Fuenres Mar Eidtan Amor**  
- **Martínez Espinoza Luis Eduardo**  
- **Ulloa Mada Daniel Elías**

---

# 🚗 Slider App — Juego de Carreras con Supabase

Slider App es una aplicación creada en **Flutter** que permite a los jugadores registrar y actualizar su puntuación dentro de un sistema conectado a **Supabase**.  
El objetivo principal del proyecto es demostrar cómo integrar un backend moderno con una app móvil sencilla y funcional.

---

## 🔧 Configuración de Variables de Entorno

Este proyecto utiliza **.env** para manejar credenciales sensibles como claves de Supabase y datos de autenticación.

### Configuración Inicial

1. Copia el archivo de ejemplo:

```bash
cp .env.example .env
```

2. Edita el archivo `.env` con tus valores reales:

```env
# Supabase Configuration
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_anon_key_aqui

# Authentication
AUTH_EMAIL=tu_email@example.com
AUTH_PASSWORD=tu_password_aqui
```

3. El archivo `.env` no debe subirse a GitHub (ya está en `.gitignore`).

---

## 🚀 Instalación y Ejecución

1. Instala dependencias:

```bash
flutter pub get
```

2. Configura tu archivo `.env`.

3. Ejecuta el proyecto:

```bash
flutter run
```

---

## 🏗️ Arquitectura del Proyecto

El proyecto sigue una arquitectura basada en servicios, manteniendo una capa limpia para la lógica relacionada con Supabase.

```
lib/
├── main.dart                    # Punto de entrada, carga .env
├── services/
│   └── supabase_service.dart    # Lógica central de Supabase
└── pages/
    └── [pantallas del juego y puntajes]
```

### 🧠 SupabaseService

Centraliza todas las operaciones relacionadas con la base de datos:

- **signIn()** → Autenticación del usuario configurado vía .env  
- **insertPlayer()** → Inserta un jugador nuevo  
- **updatePlayer()** → Actualiza el puntaje existente  
- **checkAndUpsertPlayer()** → Verifica si el jugador existe y realiza upsert inteligente  
- **retrievePoints()** → Obtiene el puntaje actual del jugador  

Esta clase facilita que la app se mantenga limpia y modular.

---

## 🎮 Lógica del Juego

Aunqe el proyecto es sencillo, mantiene una estructura clara:

- Un auto se desplaza por la pista.
- El usuario interactúa con la interfaz para mover el vehículo.
- Al finalizar la partida, el puntaje se envía a Supabase.
- Si el jugador ya existe, se actualiza su puntuación.
- Si es nuevo, se crea automáticamente.

También incluye el uso de imágenes externas para representar los autos.

---

## 🔒 Seguridad

- Nunca compartas tu archivo `.env`.
- Usa `.env.example` para distribuir la estructura sin exponer datos.
- Supabase gestiona la autenticación de manera segura con su clave pública (anon key).

---

## 📦 Dependencias Principales

- **supabase_flutter: ^2.10.3** – Cliente de Supabase para Flutter  
- **flutter_dotenv: ^5.1.0** – Manejo de variables de entorno  

---

## 📘 Documentación de Apoyo

Si es tu primer proyecto en Flutter, estos recursos te serán útiles:

- [Codelab oficial](https://docs.flutter.dev/get-started/codelab)
- [Cookbook de Flutter](https://docs.flutter.dev/cookbook)
- [Documentación completa](https://docs.flutter.dev/)

---

## 🪪 Créditos

- **Flutter** – Framework para apps nativas  
- **Supabase** – Backend moderno como servicio  
- **flutter_dotenv** – Variables de entorno  
- **freepngimg** – Icono del auto  