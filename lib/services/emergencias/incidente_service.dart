import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_sos/models/emergencias/incidente_model.dart';
import 'package:auto_sos/models/emergencias/incidente_detalle_model.dart';
import 'package:auto_sos/core/config.dart';

class IncidenteService {
  /// Crear un nuevo incidente
  Future<Incidente> crearIncidente({
    required double latitud,
    required double longitud,
    required int usuarioId,
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.incidentesCrear}');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({
          'latitud': latitud,
          'longitud': longitud,
          'usuario_id': usuarioId,
        }),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return Incidente.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al crear incidente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener un incidente por su ID
  Future<Incidente> obtenerIncidente({
    required int incidenteId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.incidentesObtener}$incidenteId',
    );

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Incidente.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        throw Exception('Incidente no encontrado');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al obtener incidente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener todos los incidentes del usuario
  Future<Map<String, dynamic>> obtenerIncidentesUsuario({
    required int usuarioId,
    required String token,
    int pagina = 1,
    int limite = 10,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.incidentesPorUsuario}$usuarioId'
      '?pagina=$pagina&limite=$limite',
    );

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return {
          'datos': (jsonResponse['datos'] as List)
              .map((item) => Incidente.fromJson(item as Map<String, dynamic>))
              .toList(),
          'total': jsonResponse['total'] as int,
          'pagina': jsonResponse['pagina'] as int,
          'limite': jsonResponse['limite'] as int,
          'total_paginas': jsonResponse['total_paginas'] as int,
        };
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al obtener incidentes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Actualizar un incidente existente
  Future<Incidente> actualizarIncidente({
    required int incidenteId,
    required String token,
    double? latitud,
    double? longitud,
    String? estado,
    String? prioridad,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.incidentesActualizar}$incidenteId',
    );

    final payload = <String, dynamic>{};
    if (latitud != null) payload['latitud'] = latitud;
    if (longitud != null) payload['longitud'] = longitud;
    if (estado != null) payload['estado'] = estado;
    if (prioridad != null) payload['prioridad'] = prioridad;

    try {
      final response = await http.put(
        url,
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Incidente.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        throw Exception('Incidente no encontrado');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception(
          'Error al actualizar incidente: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Enviar emergencia con ubicación actual (acción principal)
  Future<Incidente> enviarEmergenciaActual({
    required double latitud,
    required double longitud,
    required int usuarioId,
    required String token,
  }) async {
    return await crearIncidente(
      latitud: latitud,
      longitud: longitud,
      usuarioId: usuarioId,
      token: token,
    );
  }

  /// Obtener detalle completo de un incidente
  Future<IncidenteDetalle> obtenerDetalle({
    required int incidenteId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.incidentesDetalle}$incidenteId/detalle',
    );

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        return IncidenteDetalle.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Incidente no encontrado');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al obtener detalle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener el incidente activo (EN_PROCESO) del usuario, o null si no hay
  Future<Incidente?> obtenerActivoPorUsuario({
    required int usuarioId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.incidentesActivoPorUsuario}$usuarioId/activo',
    );

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        return Incidente.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al obtener incidente activo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Cancelar un incidente
  Future<Incidente> cancelarIncidente({
    required int incidenteId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.incidentesObtener}$incidenteId/cancelar',
    );

    try {
      final response = await http.patch(
        url,
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Incidente.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        throw Exception('Incidente no encontrado');
      } else if (response.statusCode == 409) {
        final error = jsonDecode(response.body);
        throw Exception(
          error['detail'] ?? 'No se puede cancelar este incidente',
        );
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al cancelar incidente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
