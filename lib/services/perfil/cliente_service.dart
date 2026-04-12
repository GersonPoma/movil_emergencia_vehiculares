import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config.dart';
import '../../models/perfil/cliente_model.dart';

class ClienteService {
  /// Registra un nuevo cliente
  /// Retorna ClienteSalida si el registro es exitoso
  /// Lanza una excepción si falla
  Future<ClienteSalida> registrarCliente({
    required String nombre,
    required String apellido,
    required String telefono,
    required String username,
    required String password,
    DateTime? fechaNacimiento,
    String? email,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.clientesRegistrar}');
    final clienteRequest = ClienteRegistrar(
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      username: username,
      password: password,
      fechaNacimiento: fechaNacimiento,
      email: email,
    );

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(clienteRequest.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return ClienteSalida.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Error en los datos');
      } else if (response.statusCode == 409) {
        throw Exception('El usuario ya existe');
      } else {
        throw Exception('Error al registrar cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene los datos del cliente actual (requiere token)
  Future<ClienteSalida> obtenerClienteActual({required String token}) async {
    // TODO: Implementar cuando tengas endpoint de cliente actual
    throw UnimplementedError();
  }

  /// Actualiza los datos del cliente
  Future<ClienteSalida> actualizarCliente({
    required int clienteId,
    required String token,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    DateTime? fechaNacimiento,
  }) async {
    // TODO: Implementar cuando necesites editar perfil
    throw UnimplementedError();
  }
}
