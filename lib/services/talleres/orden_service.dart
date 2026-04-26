import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_sos/core/config.dart';
import 'package:auto_sos/models/talleres/orden_servicio_model.dart';

class OrdenService {
  Future<OrdenServicio?> obtenerPorIncidente(
    int incidenteId,
    String token,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.ordenPorIncidente}$incidenteId',
    );

    final response = await http.get(
      url,
      headers: ApiConfig.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      return OrdenServicio.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else if (response.statusCode == 404) {
      return null;
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado');
    } else {
      throw Exception('Error al obtener orden: ${response.statusCode}');
    }
  }
}
