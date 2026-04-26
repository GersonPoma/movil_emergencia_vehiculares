import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:auto_sos/core/config.dart';
import 'package:auto_sos/screens/talleres/orden_servicio_screen.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'emergencias_channel',
    'Emergencias',
    description: 'Notificaciones de emergencias vehiculares',
    importance: Importance.high,
  );

  late GlobalKey<NavigatorState> _navigatorKey;

  Future<void> inicializar({
    required int usuarioId,
    required String token,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    _navigatorKey = navigatorKey;

    await _configurarNotificacionesLocales();

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await _enviarTokenAlBackend(fcmToken, usuarioId, token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((nuevoToken) {
      _enviarTokenAlBackend(nuevoToken, usuarioId, token);
    });

    // App en foreground
    FirebaseMessaging.onMessage.listen((message) {
      _mostrarNotificacionLocal(message);
      _navegarAOrden(message.data);
    });

    // App en background, usuario toca la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navegarAOrden(message.data);
    });

    // App cerrada, usuario toca la notificación
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _navegarAOrden(initialMessage.data);
      });
    }
  }

  Future<void> _configurarNotificacionesLocales() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final data = jsonDecode(details.payload!) as Map<String, dynamic>;
          _navegarAOrden(data);
        }
      },
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _enviarTokenAlBackend(
    String fcmToken,
    int usuarioId,
    String token,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.fcmToken}$usuarioId/fcm-token',
    );
    await http.patch(
      url,
      headers: ApiConfig.getAuthHeaders(token),
      body: jsonEncode({'fcm_token': fcmToken}),
    );
  }

  void _mostrarNotificacionLocal(RemoteMessage message) {
    final titulo = message.data['titulo'] ?? 'Nueva notificación';
    final cuerpo = message.data['cuerpo'] ?? '';

    _localNotif.show(
      message.hashCode,
      titulo,
      cuerpo,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _navegarAOrden(Map<String, dynamic> data) {
    final incidenteIdStr = data['incidente_id'];
    if (incidenteIdStr == null) return;

    final incidenteId = int.tryParse(incidenteIdStr.toString());
    if (incidenteId == null) return;

    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/orden_servicio'),
        builder: (_) => OrdenServicioScreen(incidenteId: incidenteId),
      ),
      (route) => route.isFirst,
    );
  }
}
