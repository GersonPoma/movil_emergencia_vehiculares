/// Configuración centralizada de la aplicación
class ApiConfig {
  // Base URL del API
  static const String baseUrl = 'http://192.168.100.90:8000';

  // Para emulador Android, cambiar a:
  // static const String baseUrl = 'http://10.0.2.2:8000';

  // Endpoints
  static const String authLogin = '/auth/login';
  static const String clientesRegistrar = '/clientes/registrar';
  static const String clientesListar = '/clientes/';
  static const String clientesObtener = '/clientes/'; // + id
  static const String clientesActualizar = '/clientes/'; // + id
  static const String clientesEliminar = '/clientes/'; // + id

  // Endpoints - Vehículos
  static const String vehiculosCrear = '/vehiculos/';
  static const String vehiculosListar = '/vehiculos/';
  static const String vehiculosPorCliente =
      '/vehiculos/cliente/'; // + cliente_id
  static const String vehiculosActualizar =
      '/vehiculos/cliente/'; // + cliente_id
  static const String vehiculosEliminar = '/vehiculos/cliente/'; // + cliente_id

  // Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };

  /// Obtiene headers con token de autenticación
  static Map<String, String> getAuthHeaders(String token) {
    return {...defaultHeaders, 'Authorization': 'Bearer $token'};
  }
}
