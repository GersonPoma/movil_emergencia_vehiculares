import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_sos/core/config.dart';

class CloudinaryService {
  Future<String?> subirArchivo(File archivo) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/auto/upload',
    );

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', archivo.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final data = json.decode(await response.stream.bytesToString());
        return data['secure_url'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
