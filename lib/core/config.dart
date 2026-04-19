/// Credenciales de Cloudinary para subir evidencias
class CloudinaryConfig {
  static const String cloudName = 'dgwbo6gvt'; // reemplaza con tu cloud name
  static const String uploadPreset =
      'evidencias_app'; // reemplaza con tu upload preset
}

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

  // Endpoints - Emergencias/Incidentes
  static const String incidentesCrear = '/incidentes/';
  static const String incidentesListar = '/incidentes/';
  static const String incidentesPorUsuario =
      '/incidentes/usuario/'; // + usuario_id
  static const String incidentesObtener = '/incidentes/'; // + incidente_id
  static const String incidentesActualizar = '/incidentes/'; // + incidente_id

  // Endpoints - Evidencias
  static const String evidenciasCrear = '/evidencias/';
  static const String evidenciasPorIncidente =
      '/evidencias/incidente/'; // + incidente_id
  static const String evidenciasEliminar = '/evidencias/'; // + evidencia_id

  // Endpoints - IA
  static const String iaProcesarEvidencia = '/ia/procesar-evidencia';

  // Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };

  /// Obtiene headers con token de autenticación
  static Map<String, String> getAuthHeaders(String token) {
    return {...defaultHeaders, 'Authorization': 'Bearer $token'};
  }
}
