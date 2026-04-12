class ClienteRegistrar {
  final String nombre;
  final String apellido;
  final DateTime? fechaNacimiento;
  final String? email;
  final String telefono;
  final String username;
  final String password;

  ClienteRegistrar({
    required this.nombre,
    required this.apellido,
    this.fechaNacimiento,
    this.email,
    required this.telefono,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'apellido': apellido,
    'fecha_nacimiento': fechaNacimiento?.toIso8601String().split('T')[0],
    'email': email,
    'telefono': telefono,
    'username': username,
    'password': password,
  };
}

class ClienteSalida {
  final int id;
  final String nombre;
  final String apellido;
  final DateTime? fechaNacimiento;
  final String? email;
  final String telefono;
  final int usuarioId;

  ClienteSalida({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.fechaNacimiento,
    this.email,
    required this.telefono,
    required this.usuarioId,
  });

  factory ClienteSalida.fromJson(Map<String, dynamic> json) {
    return ClienteSalida(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'] as String)
          : null,
      email: json['email'] as String?,
      telefono: json['telefono'] as String,
      usuarioId: json['usuario_id'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'apellido': apellido,
    'fecha_nacimiento': fechaNacimiento?.toIso8601String().split('T')[0],
    'email': email,
    'telefono': telefono,
    'usuario_id': usuarioId,
  };

  String get nombreCompleto => '$nombre $apellido';
}
