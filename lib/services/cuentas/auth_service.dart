import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config.dart';
import '../../models/cuentas/usuario_model.dart';

class AuthService {
  /// Autentica un usuario con username y password
  /// Retorna TokenResponse si la autenticación es exitosa
  /// Lanza una excepción si falla
  Future<TokenResponse> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authLogin}');
    final loginRequest = LoginRequest(username: username, password: password);

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(loginRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return TokenResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw Exception('Usuario o contraseña incorrectos');
      } else {
        throw Exception('Error al autenticarse: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Verifica si el token es válido
  Future<bool> validateToken(String token) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/validate');
      final response = await http.post(
        url,
        headers: ApiConfig.getAuthHeaders(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Logout del usuario (si existe en el backend)
  Future<void> logout() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/logout');
      await http.post(url);
    } catch (e) {
      // Ya que es logout, no es crítico si falla
      print('Error al hacer logout: $e');
    }
  }
}
