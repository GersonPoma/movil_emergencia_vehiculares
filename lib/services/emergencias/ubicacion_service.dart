import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class UbicacionService {
  static final UbicacionService _instance = UbicacionService._internal();

  factory UbicacionService() {
    return _instance;
  }

  UbicacionService._internal();

  /// Verifica y solicita permisos de ubicación
  Future<bool> solicitarPermiso() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Verifica si el permiso de ubicación está concedido
  Future<bool> verificarPermiso() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Habilita los servicios de ubicación en el dispositivo
  Future<void> habilitarServicios() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
    }
  }

  /// Obtiene la ubicación actual del usuario
  /// Solicita permiso si es necesario
  Future<Position> obtenerUbicacionActual() async {
    bool tienePermiso = await verificarPermiso();

    if (!tienePermiso) {
      tienePermiso = await solicitarPermiso();
    }

    if (!tienePermiso) {
      throw Exception('Permiso de ubicación denegado');
    }

    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      await habilitarServicios();
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene un stream de actualizaciones de ubicación en tiempo real
  Stream<Position> obtenerUbicacionTiempoReal({
    double distanciaFiltro = 5, // en metros
    int intervaloActualizacion = 1000, // en milisegundos
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanciaFiltro.toInt(),
        timeLimit: Duration(milliseconds: intervaloActualizacion),
      ),
    );
  }

  /// Calcula la distancia entre dos coordenadas en metros
  static double calcularDistancia(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Obtiene la dirección desde coordenadas (reverse geocoding)
  /// Nota: Requiere integración adicional con un servicio de geocoding
  /// como Google Maps o Similar
  Future<String> obtenerDireccion(double latitud, double longitud) async {
    // Esta es una implementación básica
    // Para reverse geocoding completo, integra con geocoding package
    return '$latitud, $longitud';
  }
}
