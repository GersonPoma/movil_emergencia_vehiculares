import 'dart:convert';

import 'package:auto_sos/core/config.dart';
import 'package:http/http.dart' as http;

class ProcesamientoIaException implements Exception {
  final String message;
  final String? code;
  final int statusCode;

  ProcesamientoIaException({
    required this.message,
    required this.statusCode,
    this.code,
  });

  bool get isAudioInvalido => code == 'AUDIO_INVALIDO';
  bool get isImagenInvalida => code == 'IMAGEN_INVALIDA';

  @override
  String toString() => message;
}

class ProcesamientoIaService {
  Future<Map<String, dynamic>> procesarEvidencia({
    required int incidenteId,
    required String urlAudio,
    required List<String> urlsFotos,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.iaProcesarEvidencia}',
    );

    final response = await http.post(
      url,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode({
        'id_incidente': incidenteId,
        'url_audio': urlAudio,
        'urls_fotos': urlsFotos,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final payload = _decodeBody(response.body);
    final detail = payload?['detail'];

    if (detail is Map<String, dynamic>) {
      throw ProcesamientoIaException(
        message: (detail['mensaje'] ?? 'Error al procesar evidencias con IA')
            .toString(),
        code: detail['codigo']?.toString(),
        statusCode: response.statusCode,
      );
    }

    throw ProcesamientoIaException(
      message: detail?.toString() ?? 'Error al procesar evidencias con IA',
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic>? _decodeBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
