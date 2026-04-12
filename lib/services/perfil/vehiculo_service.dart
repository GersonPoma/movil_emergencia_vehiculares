import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config.dart';
import '../../models/perfil/vehiculo_model.dart';

class VehiculoService {
  /// Obtiene el vehículo de un cliente específico
  Future<VehiculoSalida?> obtenerPorCliente({
    required int clienteId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.vehiculosPorCliente}$clienteId',
    );

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return VehiculoSalida.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        return null; // No tiene vehículo
      } else {
        throw Exception('Error al obtener vehículo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Crea un nuevo vehículo para un cliente
  Future<VehiculoSalida> crear({
    required String placa,
    required String modelo,
    required String color,
    required int clienteId,
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.vehiculosCrear}');
    final vehiculoRequest = VehiculoCrear(
      placa: placa,
      modelo: modelo,
      color: color,
      clienteId: clienteId,
    );

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(vehiculoRequest.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return VehiculoSalida.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Error en los datos');
      } else if (response.statusCode == 409) {
        throw Exception('La placa ya existe');
      } else {
        throw Exception('Error al crear vehículo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Actualiza el vehículo de un cliente
  Future<VehiculoSalida> actualizar({
    required int clienteId,
    required String token,
    String? placa,
    String? modelo,
    String? color,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.vehiculosActualizar}$clienteId',
    );
    final vehiculoRequest = VehiculoActualizar(
      placa: placa,
      modelo: modelo,
      color: color,
    );

    try {
      final response = await http.put(
        url,
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(vehiculoRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return VehiculoSalida.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        throw Exception('Vehículo no encontrado');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Error en los datos');
      } else {
        throw Exception('Error al actualizar vehículo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Elimina el vehículo de un cliente
  Future<void> eliminar({required int clienteId, required String token}) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.vehiculosEliminar}$clienteId',
    );

    try {
      final response = await http.delete(
        url,
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode != 204) {
        throw Exception('Error al eliminar vehículo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
