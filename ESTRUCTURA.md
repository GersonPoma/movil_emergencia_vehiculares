# AutoSOS - Estructura del Proyecto Flutter

## 📱 Estructura de Carpetas

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/
│   └── cuentas/
│       ├── usuario_model.dart    # LoginRequest, TokenResponse, Usuario
│       └── index.dart            # Exporta los modelos de cuentas
├── services/
│   └── cuentas/
│       ├── auth_service.dart     # Servicio HTTP para autenticación
│       └── index.dart            # Exporta los servicios de cuentas
├── screens/
│   ├── cuentas/
│   │   ├── login_screen.dart     # Pantalla principal de login AutoSOS
│   │   └── index.dart            # Exporta las pantallas de cuentas
│   ├── login_screen.dart         # (Deprecated - usar screens/cuentas/)
│   └── ...
├── widgets/
│   ├── cuentas/
│   │   ├── login_widgets.dart    # Componentes reutilizables (LoginTextField, LoginButton, etc)
│   │   └── index.dart            # Exporta los widgets de cuentas
│   └── ...
```

## 🔐 Módulo de Cuentas (lib/*/cuentas/)

### Models (lib/models/cuentas/usuario_model.dart)
**Clases Dart que mapean los esquemas JSON del backend:**
- `LoginRequest` - Datos de login (username, password)
- `TokenResponse` - Respuesta del servidor (token, usuario, rol, privilegios)
- `Usuario` - Información del usuario

### Services (lib/services/cuentas/auth_service.dart)
**Cliente HTTP que se comunica con el backend:**
- `AuthService.login()` - POST /auth/login
- `AuthService.validateToken()` - Valida el token
- `AuthService.logout()` - Cierra la sesión

**Configuración:**
```dart
// Para emulador Android (localhost)
final String baseUrl = 'http://10.0.2.2:8000';

// Para iOS o dispositivo físico, cambiar a:
// 'http://tu-ip-local:8000'
```

### Screens (lib/screens/cuentas/login_screen.dart)
**Pantalla principal de login con:**
- Validación de formulario
- Consumo del servicio de autenticación
- Manejo de errores
- Visualización de datos del token (para demostración)

**Flujo:**
1. Usuario ingresa username y password
2. Valida campos
3. Llama a `AuthService.login()`
4. Muestra el resultado (éxito o error)
5. TODO: Guardar token en SharedPreferences
6. TODO: Navegar según el rol del usuario

### Widgets (lib/widgets/cuentas/login_widgets.dart)
**Componentes reutilizables:**
- `LoginTextField` - Campo de texto personalizado con validación
- `LoginButton` - Botón con estado de carga
- `LoginHeader` - Header con logo y título de AutoSOS
- `ErrorMessage` - Mostrador de errores

## 🚀 Cómo Usar

### Importar desde el módulo de cuentas:
```dart
import 'lib/screens/cuentas/index.dart';
import 'lib/models/cuentas/index.dart';
import 'lib/services/cuentas/index.dart';
import 'lib/widgets/cuentas/index.dart';
```

### Usar la pantalla de login:
```dart
import 'screens/cuentas/index.dart';

home: const LoginCuentasScreen(),
```

### Usar el servicio de autenticación:
```dart
import 'services/cuentas/index.dart';

final authService = AuthService();
try {
  final token = await authService.login(
    username: 'usuario123',
    password: 'password123',
  );
  print('Token: ${token.accessToken}');
  print('Rol: ${token.rol}');
} catch (e) {
  print('Error: $e');
}
```

## 📦 Dependencias Requeridas

Agregar a `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0           # Para peticiones HTTP
  shared_preferences: ^2.0.0  # Para guardar token (próximamente)
  geolocator: ^9.0.0     # Para ubicación (futuro)
  camera: ^0.10.0        # Para cámara (futuro)
```

Luego ejecutar:
```bash
flutter pub get
```

## 🔗 Próximas Implementaciones

- [ ] Guardar token en SharedPreferences
- [ ] Navegar según rol del usuario
- [ ] Pantalla de registro
- [ ] Recuperación de contraseña
- [ ] Refresh token automático
- [ ] Logout
- [ ] Persistencia de sesión

## 🎨 Tema Actual

- **Color Primario:** Azul (#1F97EA)
- **Modo Claro y Oscuro:** Soportado
- **Material Design 3:** Habilitado

## 📝 Notas

- El backend espera username y password en formato JSON
- El token retornado debe ser usado en el header `Authorization: Bearer {token}`
- Los roles disponibles son: cliente, tecnico, admin_taller
- Los privilegios se retornan como lista de strings
