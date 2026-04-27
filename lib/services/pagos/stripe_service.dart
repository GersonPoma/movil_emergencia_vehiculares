import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:auto_sos/core/config.dart';

class StripeService {
  Future<void> procesarPago({
    required int transaccionId,
    required String token,
  }) async {
    // 1. Obtener client_secret y publishable_key del backend
    final intentUrl = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.transaccionStripeIntent}$transaccionId/stripe-intent',
    );

    final intentResponse = await http.post(
      intentUrl,
      headers: ApiConfig.getAuthHeaders(token),
    );

    if (intentResponse.statusCode != 200) {
      throw Exception('Error al crear el intent de pago: ${intentResponse.statusCode}');
    }

    final intentData = jsonDecode(intentResponse.body) as Map<String, dynamic>;
    final clientSecret = intentData['client_secret'] as String;
    final publishableKey = intentData['publishable_key'] as String;

    // 2. Configurar Stripe con la publishable key
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();

    // 3. Inicializar PaymentSheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'AutoSOS',
      ),
    );

    // 4. Presentar PaymentSheet — lanza StripeException si el usuario cancela
    await Stripe.instance.presentPaymentSheet();

    // 5. Pago exitoso — actualizar estado en el backend
    await _actualizarEstado(transaccionId, token);
  }

  Future<void> _actualizarEstado(int transaccionId, String token) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.transaccionEstado}$transaccionId/estado',
    );

    final response = await http.patch(
      url,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode({'estado': 'Pagado'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Pago procesado pero error al actualizar estado: ${response.statusCode}');
    }
  }
}
