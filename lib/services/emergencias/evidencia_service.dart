import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:auto_sos/core/config.dart';
import 'package:auto_sos/models/emergencias/evidencia_model.dart';
import 'cloudinary_service.dart';

class EvidenciaService {
  final CloudinaryService _cloudinary = CloudinaryService();

  /// Sube el archivo a Cloudinary y registra la evidencia en el backend
  Future<Evidencia> subirYRegistrar({
    required File archivo,
    required String tipo, // 'Foto' | 'Audio'
    required int incidenteId,
    required String token,
  }) async {
    final url = await _cloudinary.subirArchivo(archivo);
    if (url == null)
      throw Exception('No se pudo subir el archivo a Cloudinary');

    final apiUrl = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.evidenciasCrear}',
    );

    final response = await http.post(
      apiUrl,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode({'tipo': tipo, 'url': url, 'incidente_id': incidenteId}),
    );

    if (response.statusCode == 201) {
      return Evidencia.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado');
    } else {
      throw Exception('Error al registrar evidencia: ${response.statusCode}');
    }
  }

  /// Obtener evidencias de un incidente con paginación
  Future<List<Evidencia>> obtenerPorIncidente({
    required int incidenteId,
    required String token,
    int pagina = 1,
    int limite = 50,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.evidenciasPorIncidente}$incidenteId'
      '?pagina=$pagina&limite=$limite',
    );

    final response = await http.get(
      url,
      headers: ApiConfig.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['datos'] as List)
          .map((e) => Evidencia.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado');
    } else {
      throw Exception('Error al obtener evidencias: ${response.statusCode}');
    }
  }

  /// Eliminar una evidencia por su ID
  Future<void> eliminarEvidencia({
    required int evidenciaId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.evidenciasEliminar}$evidenciaId',
    );

    final response = await http.delete(
      url,
      headers: ApiConfig.getAuthHeaders(token),
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Evidencia no encontrada');
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado');
    } else {
      throw Exception('Error al eliminar evidencia: ${response.statusCode}');
    }
  }
}
