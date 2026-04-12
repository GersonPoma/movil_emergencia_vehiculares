import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _idUsuarioKey = 'id_usuario';
  static const String _idPerfilKey = 'id_perfil';
  static const String _idTallerKey = 'id_taller';
  static const String _rolKey = 'rol';
  static const String _privilegiosKey = 'privilegios';

  /// Guarda los datos de autenticación
  Future<void> saveAuthData({
    required String token,
    required int idUsuario,
    int? idPerfil,
    int? idTaller,
    required String rol,
    required List<String> privilegios,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString(_tokenKey, token),
      prefs.setInt(_idUsuarioKey, idUsuario),
      prefs.setString(_rolKey, rol),
      prefs.setStringList(_privilegiosKey, privilegios),
      if (idPerfil != null) prefs.setInt(_idPerfilKey, idPerfil),
      if (idTaller != null) prefs.setInt(_idTallerKey, idTaller),
    ]);
  }

  /// Obtiene el token guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Obtiene el ID del usuario
  Future<int?> getIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_idUsuarioKey);
  }

  /// Obtiene el ID del perfil (cliente o técnico)
  Future<int?> getIdPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_idPerfilKey);
  }

  /// Obtiene el ID del taller (para técnicos y admin_taller)
  Future<int?> getIdTaller() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_idTallerKey);
  }

  /// Obtiene el rol del usuario
  Future<String?> getRol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rolKey);
  }

  /// Obtiene los privilegios del usuario
  Future<List<String>> getPrivilegios() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_privilegiosKey) ?? [];
  }

  /// Verifica si existe una sesión activa
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Limpia toda la sesión (logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_idUsuarioKey),
      prefs.remove(_idPerfilKey),
      prefs.remove(_idTallerKey),
      prefs.remove(_rolKey),
      prefs.remove(_privilegiosKey),
    ]);
  }

  /// Obtiene todos los datos de la sesión actual
  Future<Map<String, dynamic>> getSessionData() async {
    return {
      'token': await getToken(),
      'id_usuario': await getIdUsuario(),
      'id_perfil': await getIdPerfil(),
      'id_taller': await getIdTaller(),
      'rol': await getRol(),
      'privilegios': await getPrivilegios(),
    };
  }
}
