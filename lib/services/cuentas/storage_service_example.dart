import 'package:flutter/material.dart';

import '../../services/cuentas/storage_service.dart';

/// Ejemplo de uso del StorageService después del login
/// Este código muestra cómo acceder a los datos guardados
class StorageServiceExample {
  static Future<void> example() async {
    final storage = StorageService();

    // Verificar si está logeado
    final isLoggedIn = await storage.isLoggedIn();
    print('¿Está logeado? $isLoggedIn');

    if (isLoggedIn) {
      // Obtener datos individuales
      final token = await storage.getToken();
      final idUsuario = await storage.getIdUsuario();
      final idPerfil = await storage.getIdPerfil();
      final rol = await storage.getRol();
      final privilegios = await storage.getPrivilegios();

      print('Token: ${token?.substring(0, 20)}...');
      print('ID Usuario: $idUsuario');
      print('ID Perfil: $idPerfil');
      print('Rol: $rol');
      print('Privilegios: $privilegios');

      // Obtener todos los datos de una sola vez
      final sessionData = await storage.getSessionData();
      print('Datos de sesión: $sessionData');
    }
  }

  /// Logout - limpia toda la sesión
  static Future<void> logout() async {
    final storage = StorageService();
    await storage.clearSession();
    print('Sesión limpiada');
  }
}

/// Widget de ejemplo que muestra los datos de sesión
class SessionDisplayWidget extends StatefulWidget {
  const SessionDisplayWidget({Key? key}) : super(key: key);

  @override
  State<SessionDisplayWidget> createState() => _SessionDisplayWidgetState();
}

class _SessionDisplayWidgetState extends State<SessionDisplayWidget> {
  final _storage = StorageService();
  Map<String, dynamic>? _sessionData;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    final data = await _storage.getSessionData();
    setState(() => _sessionData = data);
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos de Sesión Guardados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('ID Usuario: ${_sessionData?['id_usuario']}'),
            Text('ID Perfil: ${_sessionData?['id_perfil']}'),
            Text('ID Taller: ${_sessionData?['id_taller']}'),
            Text('Rol: ${_sessionData?['rol']}'),
            Text(
              'Token: ${(_sessionData?['token'] as String?)?.substring(0, 20)}...',
            ),
            Text('Privilegios: ${_sessionData?['privilegios'].join(", ")}'),
          ],
        ),
      ),
    );
  }
}
