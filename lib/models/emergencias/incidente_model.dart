class Incidente {
  final int? id;
  final double latitud;
  final double longitud;
  final DateTime? fechaHora;
  final String estado;
  final String prioridad;
  final int usuarioId;

  Incidente({
    this.id,
    required this.latitud,
    required this.longitud,
    this.fechaHora,
    this.estado = 'Pendiente',
    this.prioridad = 'Incierta',
    required this.usuarioId,
  });

  // Convertir desde JSON (respuesta del servidor)
  factory Incidente.fromJson(Map<String, dynamic> json) {
    return Incidente(
      id: json['id'] as int?,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      fechaHora: json['fecha_hora'] != null
          ? DateTime.parse(json['fecha_hora'] as String)
          : null,
      estado: json['estado'] as String? ?? 'Pendiente',
      prioridad: json['prioridad'] as String? ?? 'Incierta',
      usuarioId: json['usuario_id'] as int,
    );
  }

  // Convertir a JSON (para enviar al servidor)
  Map<String, dynamic> toJson() {
    return {
      'latitud': latitud,
      'longitud': longitud,
      'estado': estado,
      'prioridad': prioridad,
    };
  }

  // Crear una copia con campos modificados
  Incidente copyWith({
    int? id,
    double? latitud,
    double? longitud,
    DateTime? fechaHora,
    String? estado,
    String? prioridad,
    int? usuarioId,
  }) {
    return Incidente(
      id: id ?? this.id,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fechaHora: fechaHora ?? this.fechaHora,
      estado: estado ?? this.estado,
      prioridad: prioridad ?? this.prioridad,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }
}
