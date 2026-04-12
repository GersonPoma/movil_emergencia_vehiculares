# 🚗 AutoSOS - Sistema de Emergencias Vehiculares

Sistema integral de atención de emergencias vehiculares que conecta conductores con técnicos disponibles, brindando respuesta rápida y eficiente ante incidentes en la carretera.

## 📋 Descripción del Proyecto

**AutoSOS** es una aplicación móvil Flutter que permite:

- **Clientes/Conductores:**
  - Registro de cuenta con datos personales
  - Gestión de un vehículo (crear, editar, eliminar)
  - Reportar emergencias con ubicación geográfica
  - Historial de emergencias atendidas

## 🏗️ Arquitectura del Proyecto

### Estructura Frontend (Flutter)
```
lib/
├── core/
│   └── config.dart                 # Configuración centralizada (API endpoints)
├── models/                         # Modelos de datos
│   ├── cuentas/                   # Modelos de autenticación
│   └── perfil/                    # Modelos de cliente, vehículo
├── services/                       # Servicios API
│   ├── cuentas/                   # Autenticación y almacenamiento
│   └── perfil/                    # Clientes, vehículos
├── screens/                        # Pantallas
│   ├── cuentas/                   # Login, registro
│   ├── perfil/                    # Gestión de perfil, vehículos
│   └── home_cliente_screen.dart   # Dashboard principal
├── widgets/                        # Componentes reutilizables
│   ├── cuentas/                   # Componentes de login
│   └── perfil/                    # Componentes del perfil
└── main.dart                       # Punto de entrada
```

### Estructura Backend (FastAPI - Referencia)
```
app/
├── core/
│   ├── config.py                  # Configuración
│   ├── security.py                # JWT y autenticación
│   └── database.py                # Conexión BD
├── models/                        # Modelos de BD
├── schemas/                       # Esquemas de validación
├── services/                      # Lógica de negocio
├── routers/                       # Rutas API
└── main.py                        # Punto de entrada
```

## 🔐 Características Principales

### Autenticación
- Login con usuario y contraseña
- Generación de tokens JWT
- Almacenamiento seguro con SharedPreferences
- Navegación automática según rol del usuario
- Cierre de sesión seguro

### Gestión de Vehículos
- Registro de un vehículo por cliente
- Edición de datos del vehículo (placa, modelo, color)
- Eliminación con confirmación
- Validación de campos

### Reportar Emergencias
- Ubicación geográfica en tiempo real
- Selección de tipo de emergencia
- Descripción detallada del problema
- Historial de reportes

## 🛠️ Requisitos Previos

### Software Requerido
- **Flutter:** v3.16.0 o superior
- **Dart:** v3.4.0 o superior (incluido con Flutter)
- **Android Studio** (para desarrollo Android) o Xcode (para iOS)
- **Git:** para clonar el repositorio

### Verificar Instalación
```bash
flutter --version
dart --version
```

## 📦 Instalación

### 1. Clonar el Repositorio
```bash
git clone https://github.com/tu-usuario/movil_emergencia_vehiculares.git
cd movil_emergencia_vehiculares
```

### 2. Descargar Dependencias
```bash
flutter pub get
```

### 3. Configurar Backend
Editar `lib/core/config.dart` y actualizar la URL del servidor:
```dart
static const String baseUrl = 'http://TU_IP:8000';
```

### 4. Ejecutar la Aplicación

#### En Emulador Android
```bash
flutter run
```

#### En Dispositivo Físico
```bash
flutter run -d <device-id>
```

#### En Navegador (Web)
```bash
flutter run -d chrome
```

#### En iOS (Mac requerido)
```bash
flutter run -d all
```

## 🧪 Uso de la Aplicación

### flujo de Cliente
1. **Registro:** Crear cuenta con datos personales
2. **Agregar Vehículo:** Registrar placa, modelo y color
3. **Dashboard:** Acceder al home con opciones principales
4. **Reportar Emergencia:** Seleccionar "Reportar Emergencia" y completar el formulario
5. **Seguimiento:** Ver estado del servicio en tiempo real
6. **Historial:** Revisar emergencias pasadas

## 🔗 Configuración de Desarrollo

### Para Visual Studio Code
1. Instalar extensión "Flutter"
2. Instalar extensión "Dart"
3. Abrir proyecto en VS Code
4. Press `F5` o usar "Run and Debug" para ejecutar

### Variables de Entorno (Opcional)
Crear archivo `.env` en la raíz del proyecto:
```env
API_BASE_URL=http://192.168.100.90:8000
DEBUG_MODE=true
```

## 📱 Dependencias Principales

```yaml
- flutter: SDK
- http: ^1.1.0                    # Cliente HTTP
- shared_preferences: ^2.2.0      # Almacenamiento local
- geolocator: (pendiente)         # Geolocalización
- google_maps_flutter: (pendiente) # Mapas
```

## 🚀 Build para Producción

### Android
```bash
flutter build apk --release
# o
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📊 Testing

Ejecutar pruebas unitarias:
```bash
flutter test
```

Ejecutar pruebas en un archivo específico:
```bash
flutter test test/widget_test.dart
```

## 🔍 Estructura de API

### Endpoints Utilizados
- `POST /auth/login` - Autenticación
- `POST /clientes/registrar` - Registro de cliente
- `GET /vehiculos/cliente/{id}` - Obtener vehículo
- `POST /vehiculos/` - Crear vehículo
- `PUT /vehiculos/cliente/{id}` - Actualizar vehículo
- `DELETE /vehiculos/cliente/{id}` - Eliminar vehículo
- `POST /emergencias/` - Reportar emergencia (pendiente)
- `GET /emergencias/historial` - Historial (pendiente)

## 🐛 Solución de Problemas

### Problema: "No internet connection"
```
Solución: Verificar que la URL en ApiConfig sea correcta y accesible
```

### Problema: "Port already in use"
```
Solución: Matar el proceso con
flutter clean
flutter pub get
```

### Problema: "Build cache is invalid"
```
Solución: 
flutter clean
flutter pub get
flutter run
```

## 👥 Roles de Usuario

| Rol | Estado |
|-----|--------|
| cliente | ✅ Implementado |
| tecnico | ⏳ Próxima fase |
| admin_taller | ⏳ Próxima fase |

## 📝 Licencia

Este proyecto es desarrollado como parte del curso de Desarrollo Móvil.

## 📧 Contacto

Para preguntas o sugerencias: [correo@ejemplo.com]

## 🤝 Contribuidores

- **Angelica** - Desarrollo Principal

---

**Última actualización:** Abril 2026

